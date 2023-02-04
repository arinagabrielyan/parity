//
//  ChatViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController, Localizable {
    private var mainView = UIView()
    private var otherUserEmail: String
    private var otherUsername: String
    private var conversationId: String?
    private var messages: [Message] = []
    private var sender: Sender!
    private var isNewConverstaion = true
    private var choosenImage: UIImage? = nil

    public var companionAvatar: UIImage? = nil
    public var selfAvatarData: Data? = LocaleStorageManager.shared.profileImage

    init(otherUserEmail: String, otherUsername: String, id: String? = nil) {
        self.otherUserEmail = otherUserEmail
        self.otherUsername = otherUsername
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)

        self.sender = createSender()
        self.title = otherUsername

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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()

        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
        }
    }

    func updateLocalization() {
        title = LocalizeStrings.chat
    }

    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(.init(width: 35, height: 35), animated: true)
        button.setImage(UIImage(systemName: "plus"), for: .normal)

        button.onTouchUpInside { _ in
            self.presentInputActionSheet()
        }

        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([ button ], forStack: .left, animated: true)
    }

    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(
            title: "Attach Media", // need to localize
            message: "What would you like to attach?", // need to localize
            preferredStyle: .actionSheet
        )

        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { _ in // need to localize
            self.presentPhotoActionSheet()
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel)) // need to localize

        present(actionSheet, animated: true)
    }

    private func createSender() -> Sender? {
        guard let email = LocaleStorageManager.shared.email else { return nil }

        return Sender(senderId: email, displayName: otherUsername)
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

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        var avatar: Avatar

        // working, need redesign
        avatarView.layer.borderColor = UIColor.green.withAlphaComponent(0.8).cgColor
        avatarView.layer.borderWidth = 1

        if message.sender.senderId == LocaleStorageManager.shared.email {
            guard let imageData = selfAvatarData else { return }

            avatar = Avatar(image: UIImage(data: imageData) , initials: "")
        } else {
            avatar = Avatar(image: companionAvatar, initials: "")
        }

        avatarView.set(avatar: avatar)
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

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

        guard let message = message as? Message else { return }

        switch message.kind {
            case .photo(let photo):
                guard let imageUrl = photo.url else { return }

                ImageDownloader.load(url: imageUrl, completion: { image in
                    imageView.image = image
                })
            default: break
        }
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }

        let message = messages[indexPath.section]

        switch message.kind {
            case .photo(let photo):
                guard let imageUrl = photo.url else { return }

                let photoViewerViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "PhotoViewerViewController") as! PhotoViewerViewController

                photoViewerViewController.set(url: imageUrl)

                navigationController?.pushViewController(photoViewerViewController, animated: true)

            default: break
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(
            title: LocalizeStrings.profilePicture,
            message: LocalizeStrings.profilePictureMessage,
            preferredStyle: .actionSheet
        )

        // need to localize
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.presentCamera()
        }))
        // need to localize
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.presentPhotoPicker()
        }))
        // need to localize
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        present(imagePickerController, animated: true)
    }

    func presentPhotoPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        present(imagePickerController, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard
            let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
            let data = selectedImage.pngData(),
            let conversationId
        else { return }

        let fileName = "photo_message_" + generateNewId() + ".png"

        StorageManager.shared.sendImageInMessage(
            with: data,
            fileName: fileName) { result in
                switch result {
                    case .success(let url):
                        guard
                            let url = URL(string: url),
                            let placeholderImage = UIImage(systemName: "paperplane")
                        else { return }

                        let media = Media(url: url, placeholderImage: placeholderImage, size: .zero)
                        let message = Message(
                            sender: self.sender,
                            messageId: self.generateNewId(),
                            sentDate: Date(),
                            kind: .photo(media)
                        )

                        DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: self.otherUserEmail, message: message) { success in
                            if success {
                                debugPrint("Image sent!")
                            } else {
                                debugPrint("Image sending error!")
                            }

                        }
                    case .failure(let error):
                        debugPrint("Error: ", error.localizedDescription)
                }
            }

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
