//
//  PrivateNotesCell.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 24.01.23.
//

import UIKit

class PrivateNotesCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.backgroundColor = .clear
        containerView.layer.cornerRadius = 20
    }

    func set(note: Note) {
        titleLabel.text = note.title
        noteLabel.text = note.note
        dateLabel.text = note.date

        containerView.backgroundColor = AppColors.mainColor
        titleLabel.textColor = AppColors.textColor
        noteLabel.textColor = AppColors.textColor
        dateLabel.textColor = AppColors.textColor
    }
}
