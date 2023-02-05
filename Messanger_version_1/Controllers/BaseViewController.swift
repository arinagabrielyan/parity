//
//  BaseViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 27.01.23.
//

import UIKit

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

    func showAlert(
        title: String?,
        message: String?,
        button: String,
        buttonStyle: UIAlertAction.Style = .default,
        alertStyle: UIAlertController.Style = .alert,
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        let action = UIAlertAction(title: button, style: buttonStyle, handler: handler)

        alert.addAction(action)

        present(alert, animated: true)
    }
}
