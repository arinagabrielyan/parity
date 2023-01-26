//
//  PrivateNotesViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 23.01.23.
//

import UIKit
import LocalAuthentication

class PrivateNotesViewController: UIViewController {
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    private var needToCheckFaceID = true
    private var needToSaveNotes = false
    private var notes: [Note] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if needToCheckFaceID {
            faceIdCheck()
            fetchNotes()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if needToSaveNotes {
            needToCheckFaceID = true
            addButton.isHidden = true
            coverView.isHidden = false

            DatabaseManager.shared.save(notes: self.notes) { _ in }
        }
    }

    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self

        addButton.isHidden = true
        coverView.isHidden = false

        title = "Private notes"
    }

    private func fetchNotes() {
        DatabaseManager.shared.fetchNotes { notes in
            self.notes = notes

            self.tableView.reloadData()
        }
    }

    private func faceIdCheck() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Check Face ID for access to Private Notes"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.coverView.isHidden = true
                        self.addButton.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(
                            title: "Failed to Authenticate",
                            message: "Please try again.",
                            button: "Dissmis"
                        )
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.showAlert(
                    title: "Unavailable",
                    message: "You can't use this feature.",
                    button: "Dissmis"
                )
            }
        }
    }

    private func navigateToNewNoteViewController() {
        let createNewNoteViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "CreateNewNoteViewController") as! CreateNewNoteViewController

        createNewNoteViewController.completion = { title, note, isNewNote in
            let date = self.dateFormatter.string(from: Date())

            if isNewNote {
                self.notes.append(.init(title: title, note: note, date: date))
                self.needToCheckFaceID = false
                self.needToSaveNotes = true

                self.tableView.reloadData()
            }
        }

        needToSaveNotes = false
        createNewNoteViewController.isNewNode = true
        createNewNoteViewController.title = "New Note"
        navigationController?.pushViewController(createNewNoteViewController, animated: true)
    }

    @IBAction func addNoteButtonTapped(_ sender: UIBarButtonItem) {
        navigateToNewNoteViewController()
    }

    @IBAction func enterButtonTapped(_ sender: UIButton) {
        faceIdCheck()
    }
}
extension PrivateNotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateNotesCell", for: indexPath) as! PrivateNotesCell

        let note = notes[indexPath.row]

        cell.set(note: .init(title: note.title, note: note.note, date: note.date))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]

        let createNewNoteViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "CreateNewNoteViewController") as! CreateNewNoteViewController

        createNewNoteViewController.completion = { title, note, _ in
            let date = self.dateFormatter.string(from: Date())

            self.notes[indexPath.row] = .init(title: title, note: note, date: date)
            self.needToCheckFaceID = false
            self.needToSaveNotes = true

            self.tableView.reloadData()
        }

        needToSaveNotes = false
        let date = self.dateFormatter.string(from: Date())
        createNewNoteViewController.note = .init(title: note.title, note: note.note, date: date)
        createNewNoteViewController.title = "Edit Note"

        navigationController?.pushViewController(createNewNoteViewController, animated: true)
    }

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"

        return dateFormatter
    }
}
