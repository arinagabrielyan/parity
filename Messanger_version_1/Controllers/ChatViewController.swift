//
//  ChatViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    private var mainView = UIView()
    private var otherUserEmail: String
    private var otherUsername: String
    private var conversationId: String?
    private var messages: [Message] = []
    private var sender: Sender {
        let email = LocalStorageManager.shared.email ?? ""

        return Sender(photoUrl: "", senderId: email, displayName: otherUsername)
    }
    private var isNewConverstaion = true

    init(otherUserEmail: String, otherUsername: String, id: String? = nil) {
        self.otherUserEmail = otherUserEmail
        self.otherUsername = otherUsername
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)

        if let conversationId {
            listenForMessages(id: conversationId)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
        }
    }

    private func generateNewId() -> String {
        let randomNumber = Int.random(in: 99999...9999999)
        let shuffledEmail = String(otherUserEmail.shuffled()).toDatabaseFormat

        return shuffledEmail + "\(randomNumber)_\(Date())"
    }

    private func listenForMessages(id: String) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { result in
            switch result {
                case .success(let messages):
                    self.messages = messages
                    self.isNewConverstaion = false

                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                    }
                case .failure(let error):
                    debugPrint("Error: \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - MessagesDataSource, Delegate -

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }

        let message = Message(
            sender: sender,
            messageId: generateNewId(),
            sentDate: Date(),
            kind: .text(text)
        )

        if isNewConverstaion {
            DatabaseManager.shared.createNewConversation(otherUserEmail: otherUserEmail, otherUsername: otherUsername, firstMessage: message) { success in
                
                if success {
                    self.messages.append(message)
                    self.isNewConverstaion = false
                    debugPrint("DatabaseManager.createNewConversation.success")

                    self.messagesCollectionView.reloadData()
                } else {
                    debugPrint("DatabaseManager.createNewConversation.failed")
                }
            }
        } else {
            guard let conversationId = conversationId else { return }
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, message: message) { success in
                if success {
                    debugPrint("DatabaseManager.shared.sendMessage.success")
                } else {
                    debugPrint("DatabaseManager.shared.sendMessage.failure")
                }
            }
        }

        inputBar.inputTextView.text = ""
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }

    var currentSender: MessageKit.SenderType {
        return sender
    }
}
