//
//  UserCell.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 21.01.23.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet private weak var contactIcon: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!

    func set(username: String, email: String) {
        self.contactIcon.text = username.first?.uppercased()
        self.usernameLabel.text = username
        self.emailLabel.text = email
    }
}
