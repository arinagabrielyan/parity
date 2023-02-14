//
//  UserCell.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 21.01.23.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var contactIcon: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView = .init()

    override func layoutSubviews() {
        super.layoutSubviews()

        contactIcon.layer.borderColor = UIColor.gray.cgColor
        contactIcon.layer.borderWidth = 1

        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        avatarImageView.layer.borderWidth = 1

        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.contentMode = .scaleAspectFill

        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        containerView.layer.cornerRadius = 10
    }

    override func awakeFromNib() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor)
        ])

        activityIndicator.startAnimating()
    }

    func set(username: String, email: String, url: String? = nil) {
        if let url, !url.isEmpty  {
            ImageDownloader.load(url: URL(string: url)!) { image in
                DispatchQueue.main.async {
                    self.avatarImageView.image = image
                    self.avatarImageView.isHidden = false
                    self.contactIcon.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
        } else {
            self.avatarImageView.isHidden = true
            self.contactIcon.isHidden = false
            contactIcon.text = username.first?.uppercased()
        }

        usernameLabel.text = username
        emailLabel.text = email

        contactIcon.backgroundColor = AppColors.mainColor
        usernameLabel.textColor = AppColors.textColor
        emailLabel.textColor = AppColors.textColor
        containerView.backgroundColor = AppColors.mainColor
    }
}
