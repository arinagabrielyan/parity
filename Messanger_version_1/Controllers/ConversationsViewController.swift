//
//  ConversationsViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 15.01.23.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    private var conversations: [Conversation] = []
    private var currentEmail = LocaleStorageManager.shared.email ?? String()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        tableView.dataSource = self
        tableView.delegate = self

        startListeningForConversation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = LocalizeStrings.chat
    }

    private func startListeningForConversation() {

        showActivityIndicator()

        DatabaseManager.shared.getAllConversations(for: currentEmail) { result in
            switch result {
                case .success(let conversations):
                    self.conversations = conversations
                    self.hideActivityIndicator()
                    self.tableView.reloadData()
                case .failure(let error):
                    self.hideActivityIndicator()
                    self.showAlert( // must fix
                        title: "Uppps",
                        message: error.localizedDescription,
                        button: "Ok"
                    )
                    debugPrint("Error: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func createNewConverationButtonTapped(_ sender: UIBarButtonItem) {
        let newConversationViewController = NewConversationViewController()
        newConversationViewController.completion = { [weak self] user in
            self?.createNewConversation(user: user)
        }

        let navigationController = UINavigationController(rootViewController: newConversationViewController)

       present(navigationController, animated: true)
    }

    private func createNewConversation(user: User) {
        let chatViewController = ChatViewController(otherUserEmail: user.email, otherUsername: user.username)

        navigationController?.pushViewController(chatViewController, animated: true)
    }

    private func dowloadProfileImageUrl(email: String, completion: @escaping ((URL?) -> Void)) {
        let userProfilePhotoPath = "\(email.toDatabaseFormat)_profile_image.png"

        StorageManager.shared.downloadURL(with: userProfilePhotoPath) { result in
            switch result {
                case .success(let url):
                    completion(url)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    completion(nil)
            }
        }
    }
}

//MARK: - TableViewDataSource, Delegate -

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { conversations.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationTableViewCell", for: indexPath) as! ConversationTableViewCell

        let conversation = conversations[indexPath.row]

        cell.set(conversation: conversation)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let conversation = conversations[indexPath.row]

        let cell = tableView.cellForRow(at: indexPath) as! ConversationTableViewCell


        let chatViewController = ChatViewController(otherUserEmail: conversation.otherUserEmail, otherUsername: conversation.username, id: conversation.id)
        chatViewController.companionAvatar =  cell.avatarImageView.image

        chatViewController.title = conversation.username
        navigationController?.pushViewController(chatViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}

