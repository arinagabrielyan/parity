//
//  UserCell.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 21.01.23.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var contactIcon: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()

        contactIcon.layer.borderColor = UIColor.gray.cgColor
        contactIcon.layer.borderWidth = 1

        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        containerView.layer.cornerRadius = 10
    }

    func set(username: String, email: String) {
        contactIcon.text = username.first?.uppercased()
        usernameLabel.text = username
        emailLabel.text = email

        usernameLabel.textColor = AppColors.textColor
        emailLabel.textColor = AppColors.textColor
        containerView.backgroundColor = AppColors.mainColor
    }
}
