//
//  RegisterViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit

class RegisterViewController: BaseViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        title = String.Constants.register
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
                        LocaleStorageManager.shared.email = email
                        LocaleStorageManager.shared.username = username

                        self.hideActivityIndicator()
                        self.navigateToMainScreen()

                        DatabaseManager.shared.insert(user: User(username: username, email: email)) { _ in }
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
}
