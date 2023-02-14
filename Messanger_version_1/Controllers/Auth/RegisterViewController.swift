//
//  RegisterViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit

class RegisterViewController: BaseViewController {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var usernameTextField: UITextField!
    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var registerButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setup()
        updateLocalization()
        updateMode()
    }

    private func setup() {
        registerButton.backgroundColor = AppColors.mainButton
    }

    private func updateLocalization() {
        title = LocalizeStrings.registration
        registerButton.setTitle(LocalizeStrings.register, for: .normal)
        usernameTextField.placeholder = LocalizeStrings.username
        passwordTextField.placeholder = LocalizeStrings.password
    }

    private func updateMode() {
        containerView.backgroundColor = AppColors.blackAndWhite
        view.backgroundColor = AppColors.blackAndWhite
        usernameTextField.backgroundColor = AppColors.mainColor
        emailTextField.backgroundColor = AppColors.mainColor
        passwordTextField.backgroundColor = AppColors.mainColor

        usernameTextField.attributedPlaceholder = NSAttributedString(
            string: LocalizeStrings.username,
            attributes: [NSAttributedString.Key.foregroundColor: AppColors.placeholderColor]
        )

        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: AppColors.placeholderColor]
        )

        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: LocalizeStrings.password,
            attributes: [NSAttributedString.Key.foregroundColor: AppColors.placeholderColor]
        )
        
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
                            title: "User register error",  // need to localize
                            message: error.localizedDescription,
                            button: "Ok"  // need to localize
                        )
                }
            }
        } else {
            self.hideActivityIndicator()

            self.showAlert(
                title: "Wrong email or password!",  // need to localize
                message: nil,
                button: "Ok"  // need to localize
            )
        }
    }

    private func navigateToMainScreen() {
        let mainScreen = UIStoryboard.main.instantiateViewController(withIdentifier: "MainScreen") as! MainScreen
        navigationController?.pushViewController(mainScreen, animated: true)
    }
}
