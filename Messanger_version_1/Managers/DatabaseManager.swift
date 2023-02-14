//
//  DatabaseManager.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 08.01.23.
//

import FirebaseDatabase
import MessageKit
import UIKit

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"

        return dateFormatter
    }

    public enum UpdateUser {
        case username(String)
        case proflieImageUrl(String)
    }

    public func update(user: UpdateUser, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let email = LocaleStorageManager.shared.email else { return }

        self.database.child("users").observeSingleEvent(of: .value) { snapshot, _ in

            guard let usersDict = snapshot.value as? [[String: Any]] else { return }

            var users = usersDict.filter { $0["user_email"] as! String != email }

            var updatedUser: [String: String] = [:]

            switch user {
                case .username(let username):
                    updatedUser = [
                        "user_name": username,
                        "user_email": email,
                        "user_profile_image_url": LocaleStorageManager.shared.profileImageUrl ?? ""
                    ]
                case .proflieImageUrl:
                    updatedUser = [
                        "user_name": LocaleStorageManager.shared.username ?? "",
                        "user_email": email,
                        "user_profile_image_url": LocaleStorageManager.shared.profileImageUrl ?? ""
                    ]

            }

            users.append(updatedUser)

            self.database.child("users").setValue(users) { error, _ in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
    }

    public func insert(user: User, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        database.child(user.email.toDatabaseFormat).setValue([
            "user_name": user.username,
            "user_email": user.email,
        ]) { error, _ in

            self.database.child("users").observeSingleEvent(of: .value) { snapshot, _ in
                let newUser: [String: String] = [
                        "user_name": user.username,
                        "user_email": user.email,
                        "user_profile_image_url": user.profileImageUrl
                ]

                if var usersCollection = snapshot.value as? [[String: String]] {
                    usersCollection.append(newUser)

                    /// need to add `user` to `users` array
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        if let error {
                            completion(.failure(error))
                        } else {
                            completion(.success(true))
                        }
                    }
                } else {
                    let newCollection: [[String: String]] = [[
                            "user_name": user.username,
                            "user_email": user.email,
                            "user_profile_image_url": user.profileImageUrl
                    ]]

                    self.database.child("users").setValue(newCollection) { error, _ in
                        if let error {
                            completion(.failure(error))
                        } else {
                            completion(.success(true))
                        }
                    }
                }
            }

            if let error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    public func fetchUsers(completion: @escaping ((Result<[User], Error>) -> Void)) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let usersDict = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.fetchUsersError))
                return
            }

            let users = usersDict.map {
                User(
                    username: $0["user_name"] as! String,
                    email: $0["user_email"] as! String,
                    profileImageUrl: $0["user_profile_image_url"] as! String
                )
            }

            completion(.success(users))
        })
    }

    public func save(notes: [Note], completion: @escaping ((Bool) -> Void)) {
        guard let email = LocaleStorageManager.shared.email else { return }

        let notesToSave: [[String: String]] = notes.map {
            return [
                "title": $0.title,
                "note": $0.note,
                "date": $0.date
            ]
        }

        self.database.child("notes/\(email.toDatabaseFormat)").observeSingleEvent(of: .value) { snapshot, _ in
            if var _ = snapshot.value as? [[String: String]] {
                self.database.child("notes/\(email.toDatabaseFormat)").setValue(notesToSave) { error, _ in
                    if let _ = error {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } else {
                self.database.child("notes/\(email.toDatabaseFormat)").setValue(notesToSave) { error, _ in
                    if let _ = error {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }

    public func fetchNotes(completion: @escaping (([Note]) -> Void)) {
        guard let email = LocaleStorageManager.shared.email else { return }

        self.database.child("notes/\(email.toDatabaseFormat)").observeSingleEvent(of: .value) { snapshot, _ in
            if let usersCollection = snapshot.value as? [[String: String]] {
                let notes: [Note] = usersCollection.map {
                    return Note(title: $0["title"]!, note:  $0["note"]!, date:  $0["date"]!)
                }
                completion(notes)
            } else {
                completion([])
            }
        }
    }

    public func getUserData(for email: String, competion: @escaping ((User?) -> Void)) {
        guard let email = LocaleStorageManager.shared.email else { return }

        self.database.child("users").observeSingleEvent(of: .value) { snapshot, text in
            if let users = snapshot.value as? [[String: String]] {

                for user in users {
                    if user["user_email"] == email {
                        competion(User(username: user["user_name"]!, email: email, profileImageUrl: user["user_profile_image_url"]!))
                    }
                }
            } else {
                competion(nil)
            }
        }
    }

    public func userExists(email: String, completion: @escaping ((Bool) -> Void)) {
        let email = email.toDatabaseFormat

        database.child(email).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    public func getUsers(completion: @escaping ((Result<[User], Error>) -> Void)) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let usersDict = snapshot.value as? [ [String: String] ] else {
                completion(.failure(DatabaseError.fetchUsersError))
                return
            }

            let users = usersDict.map {
                User(
                    username: $0["user_name"]!,
                    email: $0["user_email"]!,
                    profileImageUrl: $0["user_profile_image_url"]!
                )
            }

            completion(.success(users))
        })
    }

    //MARK: - Conversation and Messages -

    public func createNewConversation(
        otherUserEmail: String,
        otherUsername: String,
        firstMessage: Message,
        compeletion: @escaping ((Bool) -> Void))
    {
        guard
            let senderEmail = LocaleStorageManager.shared.email,
            let senderUsername = LocaleStorageManager.shared.username
        else { return }

        let referenceToDatabase = database.child("\(senderEmail.toDatabaseFormat)")

        referenceToDatabase.observeSingleEvent(of: .value) { snapshot in

            guard var userNode = snapshot.value as? [String: Any] else {
                compeletion(false)
                return
            }

            let messageDate = self.dateFormatter.string(from: firstMessage.sentDate)
            var message: String = ""

            switch firstMessage.kind {
                case .text(let text):
                    message = text
                default:
                    break
            }

            let conversationId = "conversation_\(firstMessage.messageId)"

            let newConversationData = [
                "id": conversationId,
                "user_name": otherUsername,
                "other_user_email": otherUserEmail,
                "user_image_url": "",
                "latest_message": [
                    "date": messageDate,
                    "message": message,
                    "is_read": false
                ]
            ]

            let recipient_newConversationData = [
                "id": conversationId,
                "user_name": senderUsername,
                "other_user_email": senderEmail,
                "user_image_url": LocaleStorageManager.shared.profileImageUrl ?? "",
                "latest_message": [
                    "date": messageDate,
                    "message": message,
                    "is_read": false
                ]
            ]

            self.database.child("\(senderEmail.toDatabaseFormat)/conversations").observeSingleEvent(of: .value) { snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    conversations.append(recipient_newConversationData)

                    self.database.child("\(otherUserEmail.toDatabaseFormat)/conversations").setValue(conversations)
                } else {
                    self.database.child("\(otherUserEmail.toDatabaseFormat)/conversations").setValue([ recipient_newConversationData ])
                }
            }

            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)

                userNode["conversations"] = conversations

                referenceToDatabase.setValue(userNode) { error, _ in
                    if let error {
                        compeletion(false)
                        debugPrint("Error: ", error.localizedDescription)
                    }
                    
                    self.finishCreatingConversation(
                        conversationId: conversationId,
                        username: otherUsername,
                        firstMessage: firstMessage
                    ) { result in
                        switch result {
                            case .success(_):
                                debugPrint("finishCreatingConversation.success")
                            case .failure(_):
                                debugPrint("finishCreatingConversation.failure")
                        }
                    }

                    compeletion(true)
                }
            } else {
                userNode["conversations"] = [ newConversationData ]

                referenceToDatabase.setValue(userNode) { error, _ in
                    if let error {
                        compeletion(false)
                        debugPrint("Error: ", error.localizedDescription)
                    }

                    self.finishCreatingConversation(
                        conversationId: conversationId,
                        username: otherUsername,
                        firstMessage: firstMessage
                    ) { result in
                        switch result {
                            case .success(_):
                                debugPrint("finishCreatingConversation.success")
                            case .failure(_):
                                debugPrint("finishCreatingConversation.failure")
                        }
                    }
                    compeletion(true)
                }
            }
        }
    }

    func finishCreatingConversation(
        conversationId: String,
        username: String,
        firstMessage: Message,
        completion: @escaping ((Result<Bool, Error>) -> Void)
    ) {
        let messageDate = dateFormatter.string(from: firstMessage.sentDate)
        var messageText: String = ""

        switch firstMessage.kind {
            case .text(let text):
                messageText = text
            default:
                break
        }

        guard let currentEmail = LocaleStorageManager.shared.email else { return }
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "user_name": username,
            "type": firstMessage.kind.description,
            "content": messageText,
            "date": messageDate,
            "sender_email": currentEmail,
            "is_read": false
        ]

        let value: [String: Any] = [
            "messages": [ message ]
        ]

        database.child("\(conversationId)").setValue(value) { error, _ in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    public func getAllConversations(for email: String, compeletion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email.toDatabaseFormat)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                compeletion(.failure(DatabaseError.fetchConversationsError))
                return
            }

            let conversations: [Conversation] = value.compactMap({ dict in
                guard
                    let conversationId = dict["id"] as? String,
                    let otherUsername = dict["user_name"] as? String,
                    let otherUserEmail = dict["other_user_email"] as? String,
                    let otherUserImageUrl = dict["user_image_url"] as? String,
                    let latestMessage = dict["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let text = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool
                else {
                    return Conversation(
                        id: "error_id",
                        username: "error_otherUsername",
                        otherUserEmail: "error_otherUserEmail",
                        latestMessage: .init(date: "error_date", text: "error_message", isRead: false),
                        profileImageUrl: "error_url"
                    )
                }

                return Conversation(
                    id: conversationId,
                    username: otherUsername,
                    otherUserEmail: otherUserEmail,
                    latestMessage: LatestMessage(date: date, text: text, isRead: isRead),
                    profileImageUrl: otherUserImageUrl
                )
            })

            compeletion(.success(conversations))
        })
    }

    public func getAllMessagesForConversation(with id: String, compeletion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in

            guard let value = snapshot.value as? [[String: Any]] else {
                compeletion(.failure(DatabaseError.fetchConversationsError))
                return
            }

            let messages: [Message] = value.compactMap({ dict in
                guard
                    let username = dict["user_name"] as? String,
                    let _ = dict["is_read"] as? Bool,
                    let messageId = dict["id"] as? String,
                    let content = dict["content"] as? String,
                    let senderEmail = dict["sender_email"] as? String,
                    let type = dict["type"] as? String,
                    let _ = dict["date"] as? String
                else {
                    return Message(
                        sender: Sender(senderId: "", displayName: ""),
                        messageId: "",
                        sentDate: Date(),
                        kind: .text("")
                    )
                }

                var kind: MessageKind!

                if type == "photo" {
                    if let imageURL = URL(string: content),
                       let placeholder = UIImage(systemName: "paperplane") {
                        kind = .photo(Media(
                            url: imageURL,
                            placeholderImage: placeholder,
                            size: CGSize(width: 200, height: 200)
                        ))
                    }
                } else {
                    kind = .text(content)
                }

                let sender = Sender(senderId: senderEmail, displayName: username)

                return Message(sender: sender, messageId: messageId, sentDate: Date(), kind: kind)
            })

            compeletion(.success(messages))
        })
    }

    public func sendMessage(to conversationId: String, otherUserEmail: String, message: Message, compeletion: @escaping ((Bool) -> Void)) {
        database.child("\(conversationId)/messages").observeSingleEvent(of: .value) { snapshot, text in
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                compeletion(false)
                return
            }

            let messageDate = message.sentDate
            let dateStrig = self.dateFormatter.string(from: messageDate)

            var messageText: String = ""
            switch message.kind {
                case .text(let message):
                    messageText = message
                case .photo(let media):
                    guard let urlString = media.url?.absoluteString else { return }
                    messageText = urlString
                default:
                    break
            }

            guard
                let senderEmail = LocaleStorageManager.shared.email,
                let senderUsername = LocaleStorageManager.shared.username
            else { return }

            let newMessage: [String: Any] = [
                "id": message.messageId,
                "user_name": senderUsername,
                "type": message.kind.description,
                "content": messageText,
                "date": dateStrig,
                "sender_email": senderEmail,
                "is_read": false
            ]

            currentMessages.append(newMessage)

            self.database.child("\(conversationId)/messages").setValue(currentMessages) { error, _ in
                if let error {
                    debugPrint(error.localizedDescription)
                    compeletion(false)
                } else {

                    compeletion(true)

                    self.database.child("\(senderEmail.toDatabaseFormat)/conversations").observeSingleEvent(of: .value) { snapshot, text  in

                        guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                            compeletion(false)
                            return
                        }

                        var targetConversation: [String: Any] = [:]
                        var position = 0
                        for currentUserConversation in currentUserConversations {
                            if let currentId = currentUserConversation["id"] as? String, currentId == conversationId {
                                targetConversation = currentUserConversation
                                break
                            }
                            position += 1
                        }

                        let updatedValue: [String: Any] = [
                            "date": dateStrig,
                            "message": messageText,
                            "is_read": false
                        ]

                        targetConversation["latest_message"] = updatedValue
                        currentUserConversations[position] = targetConversation

                        self.database.child("\(senderEmail.toDatabaseFormat)/conversations").setValue(currentUserConversations) { error, _ in
                            if let error {
                                debugPrint("Error: \(error.localizedDescription)")
                                compeletion(false)
                                return
                            }

                            self.database.child("\(otherUserEmail.toDatabaseFormat)/conversations").observeSingleEvent(of: .value) { snapshot, text  in
                                guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                    compeletion(false)
                                    return
                                }

                                var targetConversation: [String: Any] = [:]
                                var position = 0
                                for otherUserConversation in otherUserConversations {
                                    if let currentId = otherUserConversation["id"] as? String, currentId == conversationId {
                                        targetConversation = otherUserConversation
                                        break
                                    }
                                    position += 1
                                }

                                let updatedValue: [String: Any] = [
                                    "date": dateStrig,
                                    "message": messageText,
                                    "is_read": false
                                ]

                                targetConversation["latest_message"] = updatedValue
                                targetConversation["user_image_url"] = LocaleStorageManager.shared.profileImageUrl ?? ""
                                otherUserConversations[position] = targetConversation

                                self.database.child("\(otherUserEmail.toDatabaseFormat)/conversations").setValue(otherUserConversations) { error, _ in
                                    if let error {
                                        debugPrint("Error: \(error.localizedDescription)")
                                        compeletion(false)
                                        return
                                    }

                                    compeletion(true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public func deleteConversationWith(id: String, completion: @escaping ((Bool) -> Void)) {
        guard let email = LocaleStorageManager.shared.email else { return }
        let referenceToDatabase = database.child("\(email.toDatabaseFormat)/conversations")

        var iterator = 0
        referenceToDatabase.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                for conversation in conversations {
                    if let conversationId = conversation["id"] as? String {
                        if conversationId == id { break }
                    }
                    iterator += 1
                }

                conversations.remove(at: iterator)

                referenceToDatabase.setValue(conversations) { error, _ in
                    if let error {
                        debugPrint("Error: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }

    public func deleteNote(by index: Int) {
        guard let email = LocaleStorageManager.shared.email else { return }

        self.database.child("notes/\(email.toDatabaseFormat)").observeSingleEvent(of: .value) { snapshot, _ in
            if var notes = snapshot.value as? [[String: String]] {
                notes.remove(at: index)

                self.database.child("notes/\(email.toDatabaseFormat)").setValue(notes) { error, _ in
                    if let _ = error {
                        debugPrint("Note successfully deleted!!")
                    } else {
                        debugPrint("Error: Note delete failed!!")
                    }
                }
            } else {
                debugPrint("Note delete failed!")
            }
        }

    }

    public func isRead(conversationId: String?, otherUserEmail: String) {
        guard let conversationId else { return }

        database.child("\(conversationId)/messages").observeSingleEvent(of: .value) { snpashot, text in
            guard
                var messages = snpashot.value as? [[String: Any]]
            else { return }

            guard
                let index = messages.lastIndex(where: { $0["sender_email"] as! String == otherUserEmail }),
                messages[index]["is_read"] as! Bool != true
            else { return }

            messages[index]["is_read"] = true

            self.database.child("\(conversationId)/messages").setValue(messages) { _, _ in }

            return
        }
    }

    //MARK: - DatabaseError -

    public enum DatabaseError: Error {
        case fetchUsersError
        case fetchConversationsError
    }
}
