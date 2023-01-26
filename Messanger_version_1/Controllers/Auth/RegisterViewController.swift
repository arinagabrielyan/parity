//
//  RegisterViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        title = String.Constants.register
        activityIndicator.isHidden = true
    }

    @IBAction private func registerButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let username = usernameTextField.text ?? ""

        showActivityIndicator()

        if String.validator(email, password, username: username) {
            FirebaseManager.register(email: email, password: password) { result in
                switch result {
                    case .success(_):
                        let user = User(username: username, email: email)

                        LocalStorageManager.shared.email = email
                        LocalStorageManager.shared.username = username

                        self.hideActivityIndicator()

                        self.navigateToMainScreen()

                        DatabaseManager.shared.insert(user: user) { _ in }
                    case .failure(let error):
                        self.hideActivityIndicator()

                        self.showAlert(
                            title: "User register error",
                            message: error.localizedDescription,
                            button: "Ok"
                        )
                }
            }
        } else {
            self.hideActivityIndicator()

            self.showAlert(
                title: "Wrong email or password!",
                message: nil,
                button: "Ok"
            )
        }
    }

    private func navigateToMainScreen() {
        let mainScreen = UIStoryboard.main.instantiateViewController(withIdentifier: "MainScreen") as! MainScreen
        navigationController?.pushViewController(mainScreen, animated: true)
    }

    private func showActivityIndicator() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }

    private func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}


extension UIViewController {
    func showAlert(
        title: String?,
        message: String?,
        button: String,
        buttonStyle: UIAlertAction.Style = .default,
        alertStyle: UIAlertController.Style = .alert
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        let action = UIAlertAction(title: button, style: buttonStyle)

        alert.addAction(action)

        present(alert, animated: true)
    }
}
