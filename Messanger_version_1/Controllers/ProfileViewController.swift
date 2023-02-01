//
//  ProfileViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit

class ProfileViewController: BaseViewController {
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

    @objc
    private func avatarTapped() {
        presentPhotoActionSheet()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateLocalization()
    }

    func updateLocalization() {
        title = Localize.account
        saveButton.title = Localize.save
        usernameLabel.text = Localize.username
        languageLabel.text = Localize.language
        logoutButton.titleLabel?.text = Localize.logout
    }

    private func setup() {
        changeLanguageControl.selectedSegmentIndex = Loci.lang == .en ? 0 : 1
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
            case 0: Loci.update(language: .en)
            case 1: Loci.update(language: .rus)
            default: break
        }

        updateLocalization()
    }

    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        logout()

        navigateToMainNavigationController()
    }

    @IBAction func usernameTextFieldAction(_ sender: UITextField) {
        let oldUsername = LocaleStorageManager.shared.username

        if sender.text == oldUsername {
            UIView.animate(withDuration: 0.25) {
                self.updateUsernameButton.alpha = 0
            }
            return
        }

        UIView.animate(withDuration: 0.25) {
            self.updateUsernameButton.alpha = 1
        }
    }

    private func logout() {
        LocaleStorageManager.shared.email = nil
        LocaleStorageManager.shared.username = nil
        LocaleStorageManager.shared.profileImageUrl = nil
        LocaleStorageManager.shared.profileImage = nil

        FirebaseManager.signout()
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
            title: "Profile Picture",
            message: "How would you like to select picture?",
            preferredStyle: .actionSheet
        )

        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.presentCamera()
        }))

        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.presentPhotoPicker()
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

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
