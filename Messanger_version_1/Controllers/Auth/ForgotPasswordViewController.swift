//
//  ForgotPasswordViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 14.01.23.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {
    @IBOutlet weak private var topBannerMessage: UILabel!
    @IBOutlet weak private var sendButton: UIButton!
    @IBOutlet weak private var emailTextField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateLocalization()
        updateMode()
        setup()
    }

    private func setup() {
        title = LocalizeStrings.restorePassword
        sendButton.backgroundColor = .link
    }

    private func updateLocalization() {
        topBannerMessage.text = LocalizeStrings.sendLink
        sendButton.setTitle(LocalizeStrings.send, for: .normal)
    }

    private func updateMode() {
        view.backgroundColor = AppColors.blackAndWhite
        emailTextField.backgroundColor = AppColors.mainColor
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: AppColors.placeholderColor]
        )
    }

    @IBAction private func sendButtonTapped(_ sender: UIButton) {
        let emailToSend = emailTextField.text ?? ""

        showActivityIndicator()

        FirebaseManager.resetPassword(email: emailToSend) { result in
            switch result {
                case .success(_):
                    self.hideActivityIndicator()

                    self.showAlert(
                        title: "Success",  // need to localize
                        message: "Link for recover password sent to \(emailToSend)",  // need to localize
                        button: "Ok") { _ in 
                            self.popToAuthNavigationController()
                        }
                case .failure(let error):
                    self.hideActivityIndicator()
                    self.showAlert(title: "Error", message: error.localizedDescription, button: "Ok")
            }
        }
    }

    private func popToAuthNavigationController() {
        navigationController?.popToRootViewController(animated: true)
    }
}
