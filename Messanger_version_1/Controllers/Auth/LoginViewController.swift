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
    @IBOutlet weak private var languageLabel: UILabel!
    @IBOutlet weak private var createNewAccount: UIButton!
    @IBOutlet weak private var forgotPasswordButton: UIButton!
    @IBOutlet weak private var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLocalization()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        hideActivityIndicator()
    }

    private func updateLocalization() {
        title = "Log in" // need to localize
        passwordTextField.placeholder = "Password" // need to localize
        languageLabel.text = "Language" // need to localize
        forgotPasswordButton.setTitle("forgotPassword", for: .normal) // need to localize
        loginButton.setTitle("login", for: .normal) // need to localize
        createNewAccount.setTitle("createNewAccount", for: .normal) // need to localize
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
    }

    //MARK: - Navigation -

    private func navigateToMainScreen() {
        let mainScreen = UIStoryboard.main.instantiateViewController(withIdentifier: "MainScreen") as! MainScreen

        self.navigationController?.pushViewController(mainScreen, animated: true)
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
