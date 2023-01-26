//
//  NewPasswordViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 14.01.23.
//

import UIKit

class NewPasswordViewController: UIViewController {
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if newPasswordTextField.hasText &&
            repeatPasswordTextField.hasText &&
            newPasswordTextField.text == repeatPasswordTextField.text {
//             Change password request

//             switch result {
//                case .success(_):
//                    navigateToChatListViewController()
//                case .failure(let error):
//                    debugPrint("error: ", error.localizedDescription)
//                    navigateToLoginViewController()
//            }
        } else {
            ///show label with text `Passwords don't match!`
        }
    }

    private func navigateToChatListViewController() {
        let storyboard = UIStoryboard.main

        let chatListViewController = storyboard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController

        navigationController?.pushViewController(chatListViewController, animated: true)
    }

    private func navigateToLoginViewController() {
        let storyboard = UIStoryboard.main

        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

        navigationController?.pushViewController(loginViewController, animated: true)
    }
}

//small change
