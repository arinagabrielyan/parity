//
//  PrivateNotesViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 23.01.23.
//

import UIKit
import LocalAuthentication

class PrivateNotesViewController: BaseViewController, Localizable {
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    private var needToCheckFaceID = true
    private var needToSaveNotes = false
    private var notes: [Note] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        faceIdCheck()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        unlockButton.setTitle(LocalizeStrings.unlock, for: .normal)
        updateMode()
        tableView.reloadData()
    }

    private func updateMode() {
        coverView.backgroundColor = AppColors.blackAndWhite
        unlockButton.backgroundColor = AppColors.mainButton
        view.backgroundColor = AppColors.blackAndWhite
        tableView.backgroundColor = AppColors.blackAndWhite
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if needToSaveNotes {
            DatabaseManager.shared.save(notes: self.notes) { _ in }
        }
    }

    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self

        addButton.isHidden = true
        coverView.isHidden = false
    }

   public func updateLocalization() {
        title = LocalizeStrings.privateNote
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
            let reason = LocalizeStrings.chechFaceID
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.coverView.isHidden = true
                        self.addButton.isHidden = false

                        self.fetchNotes()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(
                            title: "Failed to Authenticate", // need to localize
                            message: "Please try again.", // need to localize
                            button: "Dissmis" // need to localize
                        )
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.showAlert(
                    title: "Unavailable", // need to localize
                    message: "You can't use this feature.", // need to localize
                    button: "Dissmis" // need to localize
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
        createNewNoteViewController.title = LocalizeStrings.newNote
        navigationController?.pushViewController(createNewNoteViewController, animated: true)
    }

    //MARK: - IBAction methods -

    @IBAction func addNoteButtonTapped(_ sender: UIBarButtonItem) {
        needToCheckFaceID = false
        navigateToNewNoteViewController()
    }

    @IBAction func enterButtonTapped(_ sender: UIButton) {
        faceIdCheck()
    }
}
extension PrivateNotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { notes.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateNotesCell", for: indexPath) as! PrivateNotesCell
        cell.selectionStyle = .none

        let note = notes[indexPath.row]

        cell.set(note: .init(title: note.title, note: note.note, date: note.date))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        needToCheckFaceID = false

        let createNewNoteViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "CreateNewNoteViewController") as! CreateNewNoteViewController

        createNewNoteViewController.completion = { title, note, _ in
            let date = self.dateFormatter.string(from: Date())

            self.notes[indexPath.row] = .init(title: title, note: note, date: date)
            self.needToSaveNotes = true

            self.tableView.reloadData()
        }

        let date = dateFormatter.string(from: Date())
        createNewNoteViewController.note = .init(title: note.title, note: note.note, date: date)
        createNewNoteViewController.title = "Edit Note" // need to localize
        navigationController?.pushViewController(createNewNoteViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let conversationForDelete = notes[indexPath.row]
        if editingStyle == .delete {
            DatabaseManager.shared.deleteNote(by: indexPath.row)

            tableView.beginUpdates()
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"

        return dateFormatter
    }
}
