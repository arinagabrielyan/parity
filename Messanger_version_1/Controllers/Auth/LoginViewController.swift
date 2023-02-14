//
//  LoginViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit

class LoginViewController: BaseViewController {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var languageLabel: UILabel!
    @IBOutlet weak private var register: UIButton!
    @IBOutlet weak private var forgotPasswordButton: UIButton!
    @IBOutlet weak private var loginButton: UIButton!
    @IBOutlet weak private var modeLabel: UILabel!
    @IBOutlet weak private var modeChangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak private var languageChangeSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateLocalization()
        updateMode()

        Localize.update(language: .en)
        ModeManager.update(mode: .light)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        hideActivityIndicator()
    }

    private func setup() {
        loginButton.backgroundColor = AppColors.mainButton
        forgotPasswordButton.backgroundColor = AppColors.mainButton
    }

    private func updateLocalization() {
        title = LocalizeStrings.login
        passwordTextField.placeholder = LocalizeStrings.password
        languageLabel.text = LocalizeStrings.language
        forgotPasswordButton.setTitle(LocalizeStrings.forgotPassword, for: .normal)
        loginButton.setTitle(LocalizeStrings.login, for: .normal)
        register.setTitle(LocalizeStrings.register, for: .normal)
        modeLabel.text = LocalizeStrings.mode
        modeChangeSegmentedControl.tintColor = AppColors.textColor
    }

    private func updateMode() {
        view.backgroundColor = AppColors.blackAndWhite
        containerView.backgroundColor = AppColors.blackAndWhite
        emailTextField.backgroundColor = AppColors.mainColor
        emailTextField.textColor = AppColors.textColor
        passwordTextField.backgroundColor = AppColors.mainColor
        passwordTextField.textColor = AppColors.textColor
        languageChangeSegmentedControl.backgroundColor = AppColors.mainColor
        modeChangeSegmentedControl.backgroundColor = AppColors.mainColor

        modeChangeSegmentedControl.tintColor = AppColors.textColor

        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: AppColors.placeholderColor]
        )

        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: LocalizeStrings.password,
            attributes: [NSAttributedString.Key.foregroundColor: AppColors.placeholderColor]
        )
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

    @IBAction private func modeChangeAction(_ sender: UISegmentedControl) {
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
