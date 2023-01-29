//
//  ChatListViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 09.01.23.
//

import UIKit

class ChatListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
//    private var users: [[String: String]] = []
    private var conversations: [Conversation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
//        fetchUsers()
        startListeningForConversation()
    }

    private func setup() {
        title = "Chat_List"
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func fetchUsers() {
        DatabaseManager.shared.getUsers { result in
            switch result {
                case .success(let users):
//                    self.users = users
                    self.tableView.reloadData()
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
            }
        }
    }

    private func startListeningForConversation() {
        guard let email = LocaleStorageManager.shared.email else { return }

        DatabaseManager.shared.getAllConversations(for: email) { result in
            switch result {
                case .success(let conversations):
                    self.conversations = conversations
                    self.tableView.reloadData()
                case .failure(let error):
                    debugPrint("Error: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func newConversationBattonTapped(_ sender: UIButton) {

    }
}

//MARK: - TableViewDataSource, Delegate -

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { conversations.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell

        let conversation = conversations[indexPath.row]

        cell.avatarImageView.image = UIImage(named: "logo_messanger")
        cell.usernameLabel.text = conversation.username
        cell.messageLabel.text = conversation.latestMessage.text

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUser = conversations[indexPath.row]
//
//        guard let email = targetUser[], let username = targetUser["user_name"] else { return }
//
//        let chatViewController = ChatViewController(targetEmail: email, username: username)
//        chatViewController.title = username
//        let navigationController = UINavigationController(rootViewController: chatViewController)
//
//        modalPresentationStyle = .fullScreen
//        present(navigationController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}
