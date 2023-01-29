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
    }

    private func setup() {
        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)

        searchBar.delegate = self
        searchBar.placeholder = "Search user..."
        searchBar.becomeFirstResponder()

        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissAction))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = view.bounds
    }

    @objc
    private func dismissAction() {
        self.dismiss(animated: true)
    }

    private func update() {
        tableView.reloadData()
    }

    func searchUsers(by query: String) {
        if hasFetch {
            filterUser(with: query)
        } else {
            DatabaseManager.shared.getUsers { result in
                switch result {
                    case .success(let users):
                        self.hasFetch = true
                        self.users = users
                        self.filterUser(with: query)
                    case .failure(let error):
                        debugPrint("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    func filterUser(with term: String) {
        guard hasFetch else { return }

        let email = LocaleStorageManager.shared.email

        results = users.filter { user in
            if user.email == email {
                return false
            }
            return user.username.hasPrefix(term.lowercased())
        }

        update()
    }
}
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = results[indexPath.row].username

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let targetUser = results[indexPath.row]

        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUser)
        }
    }
}
extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }

        results.removeAll()
        searchUsers(by: text)

        if hasFetch {

        } else {
            DatabaseManager.shared.getUsers { result in
                switch result {
                    case .success(let users):
                        self.users = users
                        self.update()
                    case .failure(let error):
                        debugPrint("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
