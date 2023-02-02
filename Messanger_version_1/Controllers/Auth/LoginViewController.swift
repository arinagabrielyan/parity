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
        title = String.Constants.logIn  // need to localize
    }

    @IBAction private func loginButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        showActivityIndicator()

        if String.validator(email, password) {
            FirebaseManager.login(email: email, password: password) { result in
                LocaleStorageManager.shared.email = email

                switch result {
                    case .success(_):
                        DatabaseManager.shared.getUserData(for: email) { user in
                            if let user {
                                LocaleStorageManager.shared.username = user.username
                                LocaleStorageManager.shared.profileImageUrl = user.profileImageUrl

                                ImageDownloader.downloadProfileImage()
                            }
                        }
                        self.hideActivityIndicator()
                        self.navigateToMainScreen()
                    case .failure(let error):
                        self.hideActivityIndicator()

                        self.showAlert(
                            title: "Authentication error",  // need to localize
                            message: error.localizedDescription,
                            button: "Ok"  // need to localize
                        )
                }
            }
        } else {
            self.hideActivityIndicator()

            self.showAlert(
                title: "Login failed", // need to localize
                message: "Wrong email or password", // need to localize
                button: "Ok"  // need to localize
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
