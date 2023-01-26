//
//  ChatListCell.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 09.01.23.
//

import UIKit

class ChatListCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusAndDateLabel: UILabel! // tbd

    func set(user: User) {
        self.avatarImageView.image = user.image
        self.usernameLabel.text = user.username
        self.messageLabel.text = user.lastMessage
//      self.statusAndDateLabel.text = user.statusAndDate // tbd
    }
}
