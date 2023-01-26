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
    private var imagesPats: [URL] = []
    private var currentEmail = LocalStorageManager.shared.email ?? String()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        tableView.dataSource = self
        tableView.delegate = self

//        showIndicator()
//        startListeningForConversation()

        guard
            let email = LocalStorageManager.shared.email,
            let username = LocalStorageManager.shared.username
        else { return }

//        DatabaseManager.shared.update(user: .init(username: username, email: email)) { result in
//            switch result {
//                case .success(let success):
//                    print("")
//                case .failure(let failure):
//                    print("")
//            }
//        }
    }

    @IBAction func createNewConverationButtonTapped(_ sender: UIBarButtonItem) {
        let newConversationViewController = NewConversationViewController()
        newConversationViewController.completion = { [weak self] result in
            self?.createNewConversation(result: result)
        }

        let navigationController = UINavigationController(rootViewController: newConversationViewController)

       present(navigationController, animated: true)
    }

    private func createNewConversation(result: [String: String]) {
        guard
            let otherUserEmail = result["user_email"],
            let otherUsername = result["username"]
        else { return }

        let chatViewController = ChatViewController(otherUserEmail: otherUserEmail, otherUsername: otherUsername)

        navigationController?.pushViewController(chatViewController, animated: true)
    }

    private func startListeningForConversation() {
        guard let email = LocalStorageManager.shared.email else { return }

        showActivityIndicator()

        DatabaseManager.shared.getAllConversations(for: email) { result in
            switch result {
                case .success(let conversations):
                    self.conversations = conversations

                    let imagesPats = conversations.map { "\($0.otherUserEmail.toDatabaseFormat)_profile_image.png" }

                    imagesPats.forEach {
                        StorageManager.shared.downloadURL(with: $0) { result in
                            switch result {
                                case .success(let url):
                                    self.imagesPats.append(url)

                                    DispatchQueue.main.async {
                                        self.hideActivityIndicator()
                                        self.tableView.reloadData()
                                    }
                                case .failure(let error):
                                    print("error: \(error.localizedDescription)")
                            }
                        }
                    }
                case .failure(let error):
                    self.hideActivityIndicator()
                    debugPrint("Error: \(error.localizedDescription)")
            }
        }
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


//        let conversation = conversations[indexPath.row]
//
//        var path: URL? = nil
//
//        cell.set(conversation: conversation, url: path)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let conversation = conversations[indexPath.row]

        let chatViewController = ChatViewController(otherUserEmail: conversation.otherUserEmail, otherUsername: conversation.username, id: conversation.id)

        chatViewController.title = conversation.username
        navigationController?.pushViewController(chatViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}

