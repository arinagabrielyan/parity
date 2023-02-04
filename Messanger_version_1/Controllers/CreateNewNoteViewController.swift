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
    }

    func updateLocalization() {
        title = LocalizeStrings.newNote
        saveButton.title = LocalizeStrings.save
    }

    private func setup() {
        titleTextField.text = note?.title
        notesTextView.text = note?.note

        notesTextView.layer.cornerRadius = 10
        titleTextField.layer.cornerRadius = 10
        titleTextField.becomeFirstResponder()

        saveButton.isEnabled = false
    }

    @IBAction func titleTextFieldValueChanged(_ sender: UITextField) {
        saveButton.isEnabled = sender.hasText
    }


    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        completion?(titleTextField.text ?? "", notesTextView.text, isNewNode)

        navigationController?.popViewController(animated: true)
    }
}
