//
//  ContactsViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 15.01.23.
//

import UIKit

class UserViewController: BaseViewController, Localizable {
    @IBOutlet weak var tableView: UITableView!
    private var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        fetchUsers()
        fetchConversation()
    }

    func updateLocalization() {
        title = LocalizeStrings.useres
    }

    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.backgroundColor = AppColors.blackAndWhite
        view.backgroundColor = AppColors.blackAndWhite
        tableView.reloadData()
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

    private var conversations: [Conversation] = []
    private func fetchConversation() {
        guard let currentEmail = LocaleStorageManager.shared.email else { return }

        DatabaseManager.shared.getAllConversations(for: currentEmail) { result in
            switch result {
                case .success(let conversations):
                    self.conversations = conversations
                case .failure(let error):
                    debugPrint("Error: \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - TableViewDataSource, Delegate -

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.selectionStyle = .none

        let conversation = users[indexPath.row]

        cell.set(username: conversation.username, email: conversation.email)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var targetUser = users[indexPath.row]

        let haveConversation = conversations.filter { $0.otherUserEmail == targetUser.email }

        if !haveConversation.isEmpty {
            targetUser.conversationId = haveConversation.first!.id
        }

        let chatViewController = ChatViewController(otherUserEmail: targetUser.email, otherUsername: targetUser.username, id: targetUser.conversationId)

        let navigationController = UINavigationController(rootViewController: chatViewController)

        modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}
