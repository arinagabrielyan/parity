//
//  ConversationTableViewCell.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 17.01.23.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userAvatarLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        avatarImageView.layer.borderWidth = 1

        userAvatarLabel.layer.borderColor = UIColor.gray.cgColor
        userAvatarLabel.layer.borderWidth = 1
    }

    func set(conversation: Conversation) {
        usernameLabel.text = conversation.username
        lastMessageLabel.text = conversation.latestMessage.text
        dateLabel.text = conversation.latestMessage.date

        userAvatarLabel.text = conversation.username.first?.uppercased()
        avatarImageView.contentMode = .scaleAspectFill

        guard let url = URL(string: conversation.profileImageUrl) else { return }

        ImageDownloader.load(url: url) { image in
            guard let image else {
                self.userAvatarLabel.isHidden = false
                self.avatarImageView.isHidden = true

                return
            }

            DispatchQueue.main.async {
                self.userAvatarLabel.isHidden = true
                self.avatarImageView.isHidden = false

                self.avatarImageView.image = image
            }
        }
    }
}
