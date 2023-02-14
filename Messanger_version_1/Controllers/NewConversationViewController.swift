//
//  NewConversationViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 12.01.23.
//

import UIKit

class NewConversationViewController: UIViewController {
    private var searchBar: UISearchBar = .init()
    private var users: [User] = []
    private var results: [User] = []
    private var hasFetch = false
    var completion: ((User) -> Void)? = nil

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        fetchConversation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = view.bounds
    }

    private let messageLabel = UILabel()
    private func showUserNotFoundMessage() {
        messageLabel.text = LocalizeStrings.userNotFound
        messageLabel.textColor = AppColors.textColor
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        tableView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 200)
        ])

        messageLabel.isHidden = false
    }

    private func hideUserNotFoundMessage() {
        messageLabel.isHidden = true
        messageLabel.removeFromSuperview()
    }

    private func setup() {
        view.backgroundColor = AppColors.blackAndWhite
        tableView.backgroundColor = AppColors.blackAndWhite
        searchBar.backgroundColor = AppColors.mainColor

        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)

        searchBar.delegate = self
        searchBar.searchTextField.textColor = AppColors.textColor
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: LocalizeStrings.searchUser,
            attributes: [NSAttributedString.Key.foregroundColor: AppColors.placeholderColor]
        )
        searchBar.becomeFirstResponder()

        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizeStrings.cancel,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissAction))
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

    @objc
    private func dismissAction() {
        self.dismiss(animated: true)
    }

    private func update() {
        tableView.reloadData()
    }
}
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.selectionStyle = .none
        cell.textLabel?.text = results[indexPath.row].username
        cell.textLabel?.textColor = AppColors.textColor
        cell.backgroundColor = AppColors.mainColor

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUser = results[indexPath.row]

        var userHaveConversation = targetUser
        var alradyHaveConversation = false
        for converstaion in conversations {
            if converstaion.otherUserEmail == targetUser.email {
                userHaveConversation.conversationId = converstaion.id
                alradyHaveConversation = true
            }
        }

        if alradyHaveConversation {
            let chatViewController = ChatViewController(otherUserEmail: userHaveConversation.email, otherUsername: userHaveConversation.username, id: userHaveConversation.conversationId)

            let navigationController = UINavigationController(rootViewController: chatViewController)

            modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        } else {
            dismiss(animated: true) { [weak self] in
                self?.completion?(targetUser)
            }
        }
    }
}
extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }

        self.users.removeAll()
        self.results.removeAll()

        DatabaseManager.shared.getUsers { result in
            switch result {
                case .success(let users):
                    for user in users {
                        if user.username.uppercased().hasPrefix(text.uppercased()) {
                            self.users.append(user)
                        }
                    }

                    self.results = self.users
                    if self.results.isEmpty {
                        self.showUserNotFoundMessage()
                    } else {
                        self.hideUserNotFoundMessage()
                    }
                    self.update()
                case .failure(let error):
                    debugPrint("Error: \(error.localizedDescription)")
            }
        }
    }
}
