//
//  ProfileViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit

class ProfileViewController: BaseViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

//        downloadProfileImage()

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

    private func setup() {
        title = String.Constants.profile

        saveButton.isEnabled = false

        avatarImageView.image = UIImage(named: "icon_black")
        avatarImageView.contentMode = .scaleToFill
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))

        guard
            let email = LocalStorageManager.shared.email,
            let username = LocalStorageManager.shared.username
        else { return }

        emailLabel.text = "Email: " + email
        usernameLabel.text = "Username: " + username
    }

    private func downloadProfileImage() {
        guard let url = LocalStorageManager.shared.profileImageUrl else { return }

        ImageDownloader.load(url: URL(string: url)!) { image in
            guard let image else { return }

            DispatchQueue.main.async {
                self.avatarImageView.image = image
            }
        }
    }

    private func uploadProfileImageToDatabase() {
        guard
            let image = avatarImageView.image,
            let imageData = image.pngData()
        else { return }

        guard let email = LocalStorageManager.shared.email else { return }
        let currentUser = User(username: "", email: email)

        let fileName = currentUser.profileImageName

        StorageManager.shared.deleteData(from: fileName) { _ in // must test!!
            StorageManager.shared.uploadProfileImage(with: imageData, fileName: fileName) { result in
                switch result {
                    case .success(let url):
                        LocalStorageManager.shared.profileImageUrl = url
                        self.saveButton.isEnabled = false
                        self.hideActivityIndicator()

                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
//        showActivityIndicator()
        uploadProfileImageToDatabase()
    }

    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        logout()

        navigateToMainNavigationController()
    }

    private func logout() {
        LocalStorageManager.shared.email = nil
        LocalStorageManager.shared.username = nil
        LocalStorageManager.shared.profileImageUrl = nil

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
