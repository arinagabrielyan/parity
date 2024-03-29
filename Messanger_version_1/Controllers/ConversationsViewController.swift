//
//  ConversationsViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 15.01.23.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: BaseViewController, Localizable {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noConversationYetLabel: UILabel!
    private var conversations: [Conversation] = []
    private var currentEmail = LocaleStorageManager.shared.email ?? String()
    private var firstLoad = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if firstLoad {
            noConversationYetLabel.isHidden = !conversations.isEmpty
        }

        updateMode()
        noConversationYetLabel.text = LocalizeStrings.noConversationYet
        tableView.reloadData()
    }

    private func setup() {
        tableView.dataSource = self
        tableView.delegate = self
        noConversationYetLabel.isHidden = true
        noConversationYetLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnLabel)))

        startListeningForConversation()
        noConversationYetLabel.textColor = AppColors.textColor
    }

    func updateLocalization() {
        title = LocalizeStrings.chat
    }

    private func updateMode() {
        tableView.backgroundColor = AppColors.blackAndWhite
        view.backgroundColor = AppColors.blackAndWhite
    }

    private func startListeningForConversation() {
        showActivityIndicator()

        DatabaseManager.shared.getAllConversations(for: currentEmail) { result in
            switch result {
                case .success(let conversations):
                    self.conversations = conversations
                    self.noConversationYetLabel.isHidden = true
                    self.hideActivityIndicator()
                    self.tableView.reloadData()
                case .failure(let error):
                    self.hideActivityIndicator()
                    self.noConversationYetLabel.isHidden = false
                    debugPrint("Error: \(error.localizedDescription)")
            }

            self.firstLoad = true
        }
    }

    private func createNewConversation(user: User) {
        let chatViewController = ChatViewController(otherUserEmail: user.email, otherUsername: user.username)

        navigationController?.pushViewController(chatViewController, animated: true)
    }

    //MARK: - IBAction methods -

    @IBAction func createNewConverationButtonTapped(_ sender: UIBarButtonItem) {
        let newConversationViewController = NewConversationViewController()
        newConversationViewController.completion = { [weak self] user in
            self?.createNewConversation(user: user)
        }

        let navigationController = UINavigationController(rootViewController: newConversationViewController)

       present(navigationController, animated: true)
    }

    @objc
    func tapOnLabel() {
        noConversationYetLabel.isHidden = true
    }
}

//MARK: - TableViewDataSource, Delegate -

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { conversations.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        cell.selectionStyle = .none

        let conversation = conversations[indexPath.row]

        cell.set(conversation: conversation)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let conversation = conversations[indexPath.row]

        let cell = tableView.cellForRow(at: indexPath) as! ConversationCell

        let chatViewController = ChatViewController(otherUserEmail: conversation.otherUserEmail, otherUsername: conversation.username, id: conversation.id)
        chatViewController.companionAvatar =  cell.avatarImageView.image

        chatViewController.title = conversation.username
        navigationController?.pushViewController(chatViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let conversationForDelete = conversations[indexPath.row]
        if editingStyle == .delete {
            DatabaseManager.shared.deleteConversationWith(id: conversationForDelete.id) { _ in }

            tableView.beginUpdates()
            conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
}
