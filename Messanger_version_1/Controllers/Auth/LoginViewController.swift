//
//  LoginViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit

class LoginViewController: BaseViewController {
    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        hideActivityIndicator()
    }
    
    private func setup() {
        title = String.Constants.logIn
    }

    @IBAction private func loginButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        showActivityIndicator()

        if String.validator(email, password) {
            FirebaseManager.login(email: email, password: password) { result in

                switch result {
                    case .success(_):
                        DatabaseManager.shared.getUserData(for: email) { user in
                            if let user {
                                LocalStorageManager.shared.email = user.email
                                LocalStorageManager.shared.username = user.username
                            }
                        }

                        self.navigateToMainScreen()
                    case .failure(let error):
                        self.hideActivityIndicator()

                        self.showAlert(
                            title: "Authentication error",
                            message: error.localizedDescription,
                            button: "Ok"
                        )
                }
            }
        } else {
            self.hideActivityIndicator()

            self.showAlert(
                title: "Login failed",
                message: "Wrong email or password",
                button: "Ok"
            )
        }
    }

    @IBAction private func createNewAccountButtonTapped(_ sender: UIButton) {
        navigateToRegisterViewController()
    }

    @IBAction private func forgotPasswordButtonTapped(_ sender: UIButton) {
        navigateToForgotPasswordViewController()
    }

    //MARK: - Navigation -

    private func navigateToMainScreen() {
        let mainScreen = UIStoryboard.main.instantiateViewController(withIdentifier: "MainScreen") as! MainScreen

        self.navigationController?.pushViewController(mainScreen, animated: true)
    }

    private func navigateToChatListViewController() {
        let chatListViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController

        navigationController?.pushViewController(chatListViewController, animated: true)
    }

    private func navigateToRegisterViewController() {
        let registerViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController

        navigationController?.pushViewController(registerViewController, animated: true)
    }

    private func navigateToForgotPasswordViewController() {
        let forgotPasswordViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController

        navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
}

extension UIStoryboard {
    static var main: UIStoryboard {
        UIStoryboard(name: "Main", bundle: nil)
    }
}
