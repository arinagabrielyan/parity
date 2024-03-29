//
//  ProfileViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit

class ProfileViewController: UIViewController, Localizable {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var changeLanguageControl: UISegmentedControl!
    @IBOutlet weak var modeChangeControl: UISegmentedControl!

    private func updateMode() {
        view.backgroundColor = AppColors.blackAndWhite

        usernameTextField.backgroundColor = AppColors.mainColor
        usernameTextField.textColor = AppColors.textColor

        emailTextField.textColor = AppColors.textColor
        emailTextField.backgroundColor = AppColors.mainColor

        modeChangeControl.backgroundColor = AppColors.mainColor
        changeLanguageControl.backgroundColor = AppColors.mainColor

        changeLanguageControl.tintColor = AppColors.textColor
        modeChangeControl.tintColor = AppColors.textColor

        logoutButton.backgroundColor = AppColors.mainColor
        logoutButton.setTitleColor(AppColors.red, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        activityIndicator.isHidden = true

        saveButton.title = LocalizeStrings.save
        usernameLabel.text = LocalizeStrings.username
        languageLabel.text = LocalizeStrings.language
        logoutButton.setTitle(LocalizeStrings.logout, for: .normal)

        updateMode()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
    }

    private func setup() {
        changeLanguageControl.selectedSegmentIndex = Localize.language == .en ? 0 : 1
        modeChangeControl.selectedSegmentIndex = ModeManager.mode == .light ? 0 : 1
        saveButton.isEnabled = false
        let image: UIImage?

        if let proflieImage = LocaleStorageManager.shared.profileImage {
            image = UIImage(data: proflieImage)
        } else {
            image = UIImage(named: "icon_black")
        }

        avatarImageView.image = image
        avatarImageView.contentMode = .scaleToFill
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))

        usernameTextField.text = LocaleStorageManager.shared.username
        emailTextField.text = LocaleStorageManager.shared.email

        emailTextField.isEnabled = false
    }

    func updateLocalization() {
        title = LocalizeStrings.profile
    }

    @objc
    private func avatarTapped() {
        presentPhotoActionSheet()
    }

    private var needUpdateProfileImage: Bool = false

    private func saveProfileImage() {
        guard
            let image = avatarImageView.image,
            let imageData = image.pngData()
        else { return }

        guard
            let email = LocaleStorageManager.shared.email
        else { return }

        let fileName = User(username: "", email: email).profileImageName

        StorageManager.shared.deleteData(from: fileName) { success in
            StorageManager.shared.uploadProfileImage(with: imageData, fileName: fileName) { result in
                switch result {
                    case .success(let url):
                        LocaleStorageManager.shared.profileImageUrl = url

                        DatabaseManager.shared.update(user: .proflieImageUrl(url)) { _ in }

                        ImageDownloader.downloadProfileImage()

                        self.saveButton.isEnabled = false
                        self.hideActivityIndicator()

                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateUsername() {
        guard let username = usernameTextField.text else { return }

        showActivityIndicator()

        DatabaseManager.shared.update(user: .username(username)) { result in
            switch result {
                case .success(_):
                    self.hideActivityIndicator()
                    LocaleStorageManager.shared.username = username

                    DispatchQueue.main.async {
                        self.usernameTextField.resignFirstResponder()
                    }

                case .failure(let error):
                    self.hideActivityIndicator()
                    debugPrint("Error: ", error.localizedDescription)
            }
        }
    }

    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    // MARK: - IBAction methods -

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        showActivityIndicator()

        switch (needUpdateUsername, needUpdateProfileImage) {
            case (true, true):
                saveProfileImage()
                updateUsername()
            case (false, true):
                saveProfileImage()
            case (true, false):
                updateUsername()
            default:
                break
        }
    }

    @IBAction private func changeLanguageAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                Localize.update(language: .en)
                LocaleStorageManager.shared.isEnglishLanguage = true
            case 1:
                Localize.update(language: .rus)
                LocaleStorageManager.shared.isEnglishLanguage = false
            default: break
        }

        updateLocalization()
        saveButton.title = LocalizeStrings.save
        usernameLabel.text = LocalizeStrings.username
        languageLabel.text = LocalizeStrings.language
        logoutButton.setTitle(LocalizeStrings.logout, for: .normal)

        controllers.forEach { ($0 as? Localizable)?.updateLocalization() }
    }

    @IBAction func changeModeAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                ModeManager.update(mode: .light)
                LocaleStorageManager.shared.isDarkMode = false
            case 1:
                ModeManager.update(mode: .dark)
                LocaleStorageManager.shared.isDarkMode = true
            default: break
        }
        updateMode()
        controllers.forEach { $0.updateNavigationControllerMode() }
    }

    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        cleanCredentials()

        FirebaseManager.signout()
        navigateToMainNavigationController()
    }

    private var needUpdateUsername: Bool = false

    @IBAction func usernameTextFieldAction(_ sender: UITextField) {
        let oldUsername = LocaleStorageManager.shared.username

        if sender.text == oldUsername {
            saveButton.isEnabled = false
            needUpdateUsername = false
        } else {
            saveButton.isEnabled = true
            needUpdateUsername = true
        }
    }

    private func cleanCredentials() {
        LocaleStorageManager.shared.email = nil
        LocaleStorageManager.shared.username = nil
        LocaleStorageManager.shared.profileImageUrl = nil
        LocaleStorageManager.shared.profileImage = nil
        LocaleStorageManager.shared.isEnglishLanguage = nil
        LocaleStorageManager.shared.isDarkMode = nil
    }

    private func navigateToMainNavigationController() {
        let authNavigationController = UIStoryboard.main.instantiateViewController(withIdentifier: "AuthNavigationController") as! AuthNavigationController

        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }

        sceneDelegate.window?.rootViewController = authNavigationController
        authNavigationController.view.backgroundColor = AppColors.blackAndWhite
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(
            title: LocalizeStrings.profilePicture,
            message: LocalizeStrings.profilePictureMessage,
            preferredStyle: .actionSheet
        )

        actionSheet.addAction(UIAlertAction(title: LocalizeStrings.takePhoto, style: .default, handler: { _ in
            self.presentCamera()
        }))

        actionSheet.addAction(UIAlertAction(title: LocalizeStrings.choosePhoto, style: .default, handler: { _ in
            self.presentPhotoPicker()
        }))

        actionSheet.addAction(UIAlertAction(title: LocalizeStrings.cancel, style: .cancel))

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        present(imagePickerController, animated: true)
    }

    func presentPhotoPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        present(imagePickerController, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.avatarImageView.image = selectedImage
        self.saveButton.isEnabled = true
        needUpdateProfileImage = true
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
