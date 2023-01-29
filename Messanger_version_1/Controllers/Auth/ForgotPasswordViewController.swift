//
//  ForgotPasswordViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 14.01.23.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {
    @IBOutlet weak private var emailTextField: UITextField!

    @IBAction private func sendButtonTapped(_ sender: UIButton) {
        let emailToSend = emailTextField.text ?? ""

        showActivityIndicator()

        FirebaseManager.resetPassword(email: emailToSend) { result in
            switch result {
                case .success(_):
                    self.hideActivityIndicator()
                    self.navigateToNewPasswordViewController()
                case .failure(let error):
                    self.hideActivityIndicator()
                    self.showAlert(title: "Error", message: error.localizedDescription, button: "Ok")
            }
        }
    }

    private func navigateToNewPasswordViewController() {
        let newPasswordViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "NewPasswordViewController") as! NewPasswordViewController

        navigationController?.pushViewController(newPasswordViewController, animated: true)
    }
}
