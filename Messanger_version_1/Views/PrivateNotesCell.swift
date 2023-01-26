//
//  PrivateNotesCell.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 24.01.23.
//

import UIKit

class PrivateNotesCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func set(note: Note) {
        titleLabel.text = note.title
        noteLabel.text = note.note
        dateLabel.text = note.date
    }
}
