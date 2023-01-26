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


class BaseViewController: UIViewController {
   private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
