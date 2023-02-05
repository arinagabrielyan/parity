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
    @IBOutlet weak var updateUsernameButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var changeLanguageControl: UISegmentedControl!

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
        updateUsernameButton.setTitle(LocalizeStrings.update, for: .normal)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
    }

    private func setup() {
        changeLanguageControl.selectedSegmentIndex = Localize.language == .en ? 0 : 1
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
        updateUsernameButton.alpha = 0
    }

    func updateLocalization() {
        title = LocalizeStrings.profile
    }

    @objc
    private func avatarTapped() {
        presentPhotoActionSheet()
    }

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
        saveProfileImage()
    }

    @IBAction func updateUsernameButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text else { return }

        showActivityIndicator()

        DatabaseManager.shared.update(user: .username(username)) { result in
            switch result {
                case .success(_):
                    UIView.animate(withDuration: 0.25) {
                        self.updateUsernameButton.alpha = 0
                    }
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
        updateUsernameButton.setTitle(LocalizeStrings.update, for: .normal)

        controllers.forEach { ($0 as? Localizable)?.updateLocalization() }
    }

    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        cleanCredentials()

        FirebaseManager.signout()
        navigateToMainNavigationController()
    }

    @IBAction func usernameTextFieldAction(_ sender: UITextField) {
        let oldUsername = LocaleStorageManager.shared.username

        if sender.text == oldUsername {
            UIView.animate(withDuration: 0.25) {
                self.updateUsernameButton.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.updateUsernameButton.alpha = 1
                self.updateUsernameButton.transform = .init(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                UIView.animate(withDuration: 0.25) {
                    self.updateUsernameButton.transform = .init(scaleX: 1.0, y: 1.0)
                }
            }
        }
    }

    private func cleanCredentials() {
        LocaleStorageManager.shared.email = nil
        LocaleStorageManager.shared.username = nil
        LocaleStorageManager.shared.profileImageUrl = nil
        LocaleStorageManager.shared.profileImage = nil
        LocaleStorageManager.shared.isEnglishLanguage = nil
    }

    private func navigateToMainNavigationController() {
        let authNavigationController = UIStoryboard.main.instantiateViewController(withIdentifier: "AuthNavigationController") as! AuthNavigationController

        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
           sceneDelegate.window?.rootViewController = authNavigationController
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
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}