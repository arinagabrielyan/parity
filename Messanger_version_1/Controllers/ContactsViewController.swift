//
//  ContactsViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 15.01.23.
//

import UIKit

class ContactsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        fetchUsers()
    }

    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self

        title = "Users"
    }

    private func fetchUsers() {
        DatabaseManager.shared.getUsers { result in
            switch result {
                case .success(let users):
                    self.users = users
                    self.tableView.reloadData()
                case .failure(let error):
                    debugPrint("\(#function) error: ", error.localizedDescription)
            }
        }
    }
}

//MARK: - TableViewDataSource, Delegate -

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell

        let conversation = users[indexPath.row]

        cell.set(username: conversation.username, email: conversation.email)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUser = users[indexPath.row]

        let chatViewController = ChatViewController(otherUserEmail: targetUser.email, otherUsername: targetUser.username)

        let navigationController = UINavigationController(rootViewController: chatViewController)

        modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 50 }
}

