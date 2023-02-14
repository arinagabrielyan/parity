//
//  CreateNewNoteViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 24.01.23.
//

import UIKit

class CreateNewNoteViewController: UIViewController, Localizable {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    private var oldContent: String = ""

    var note: Note? = nil
    var isNewNode = false

    public var completion: ((String, String, Bool) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateLocalization()

        view.backgroundColor = AppColors.blackAndWhite
        titleTextField.backgroundColor = AppColors.mainColor
        notesTextView.backgroundColor = AppColors.mainColor
        titleTextField.textColor = AppColors.textColor
        notesTextView.textColor = AppColors.textColor
    }

    func updateLocalization() {
        title = LocalizeStrings.newNote
        saveButton.title = LocalizeStrings.save
    }

    private func setup() {
        titleTextField.text = note?.title
        notesTextView.text = note?.note

        notesTextView.layer.cornerRadius = 10
        notesTextView.delegate = self
        titleTextField.layer.cornerRadius = 10
        titleTextField.becomeFirstResponder()

        saveButton.isEnabled = false
        oldContent = notesTextView.text
    }

    @IBAction func titleTextFieldValueChanged(_ sender: UITextField) {
        saveButton.isEnabled = sender.hasText
    }


    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        completion?(titleTextField.text ?? "", notesTextView.text, isNewNode)

        navigationController?.popViewController(animated: true)
    }
}
extension CreateNewNoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if !isNewNode {
            saveButton.isEnabled = oldContent != textView.text
        } else {
            saveButton.isEnabled = textView.hasText
        }
    }
}
