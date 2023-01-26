//
//  DatabaseManager.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 08.01.23.
//

import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"

        return dateFormatter
    }

    public func update(user: User, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let email = LocalStorageManager.shared.email else { return }

        self.database.child("users").observeSingleEvent(of: .value) { snapshot, _ in

            guard let usersDict = snapshot.value as? [[String: Any]] else { return }

            var users = usersDict.filter { $0["user_email"] as! String != email }


            let updatedUser: [String: String] = [
                "username": user.username,
                "user_email": user.email,
                "user_url": user.url
            ]

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
                        "username": user.username,
                        "user_email": user.email,
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
                            "username": user.username,
                            "user_email": user.email,
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

    public func save(notes: [Note], completion: @escaping ((Bool) -> Void)) {
        guard let email = LocalStorageManager.shared.email else { return }

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
        guard let email = LocalStorageManager.shared.email else { return }

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
        database.child("\(email.toDatabaseFormat)").observeSingleEvent(of: .value) { snapshot in
            guard
                let userData = snapshot.value as? [String: Any],
                let userEmail = userData["user_email"] as? String,
                let username = userData["user_name"] as? String,
                let userUrl = userData["user_url"] as? String
            else {
                competion(nil)
                return
            }

            competion(User(username: username, email: userEmail, url: userUrl))
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

    public func getUsers(completion: @escaping ((Result<[[String: String]], Error>) -> Void)) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let users = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.fetchUsersError))
                return
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
            let senderEmail = LocalStorageManager.shared.email,
            let senderUsername = LocalStorageManager.shared.username
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
                "username": otherUsername,
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": messageDate,
                    "message": message,
                    "is_read": false
                ]
            ]

            let recipient_newConversationData = [
                "id": conversationId,
                "username": senderUsername,
                "other_user_email": senderEmail,
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

    private func finishCreatingConversation(
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

        let currentEmail = LocalStorageManager.shared.email
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "username": username,
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
                    let otherUsername = dict["username"] as? String,
                    let otherUserEmail = dict["other_user_email"] as? String,
                    let latestMessage = dict["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let text = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool
                else {
                    return Conversation(
                        id: "error_id",
                        username: "error_otherUsername",
                        otherUserEmail: "error_otherUserEmail",
                        latestMessage: .init(date: "error_date", text: "error_message", isRead: false)
                    )
                }

                return Conversation(
                    id: conversationId,
                    username: otherUsername,
                    otherUserEmail: otherUserEmail,
                    latestMessage: LatestMessage(date: date, text: text, isRead: isRead)
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
                    let username = dict["username"] as? String,
                    let _ = dict["is_read"] as? Bool,
                    let messageId = dict["id"] as? String,
                    let content = dict["content"] as? String,
                    let senderEmail = dict["sender_email"] as? String,
                    let _ = dict["type"] as? String,
                    let _ = dict["date"] as? String
                else {
                    return Message(
                        sender: Sender(photoUrl: "", senderId: "", displayName: ""),
                        messageId: "",
                        sentDate: Date(),
                        kind: .text("")
                    )
                }

                let sender = Sender(photoUrl: "", senderId: senderEmail, displayName: username)

                return Message(sender: sender, messageId: messageId, sentDate: Date(), kind: .text(content))
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
                default:
                    break
            }

            guard
                let senderEmail = LocalStorageManager.shared.email,
                let senderUsername = LocalStorageManager.shared.username
            else { return }

            let newMessage: [String: Any] = [
                "id": message.messageId,
                "username": senderUsername,
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

                        let updatedValue: [String: Any] = [
                            "date": dateStrig,
                            "message": messageText,
                            "is_read": false
                        ]

                        var targetConversation: [String: Any] = [:]
                        var position = 0
                        for currentUserConversation in currentUserConversations {
                            if let currentId = currentUserConversation["id"] as? String, currentId == conversationId {
                                targetConversation = currentUserConversation
                                break
                            }
                            position += 1
                        }

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

                                let updatedValue: [String: Any] = [
                                    "date": dateStrig,
                                    "message": messageText,
                                    "is_read": false
                                ]

                                var targetConversation: [String: Any] = [:]
                                var position = 0
                                for otherUserConversation in otherUserConversations {
                                    if let currentId = otherUserConversation["id"] as? String, currentId == conversationId {
                                        targetConversation = otherUserConversation
                                        break
                                    }
                                    position += 1
                                }

                                targetConversation["latest_message"] = updatedValue
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

//    public func isRead(conversationId: String, otherUserEmail: String) {
//        database.child("\(conversationId)/messages").observeSingleEvent(of: .value) { snpashot, text in
//            guard
//                let messages = snpashot.value as? [[String: Any]]
//            else { return }
//
//            let onlyOtherUserMessages: [[String: Any]] = messages.compactMap {
//                if $0["sender_email"] as! String == otherUserEmail {
//                    return $0
//                } else {
//                    return nil
//                }
//            }
//
//            let newMessages = onlyOtherUserMessages.map {
//               if let username = $0["username"] as? String,
//                    let _ = $0["is_read"] as? Bool,
//                    let messageId = $0["id"] as? String,
//                    let content = $0["content"] as? String,
//                    let senderEmail = $0["sender_email"] as? String,
//                    let type = $0["type"] as? String,
//                    let date = $0["date"] as? String
//                {
//                   return [
//                       "id": messageId,
//                       "username": username,
//                       "type": type,
//                       "content": content,
//                       "date": date,
//                       "sender_email": senderEmail,
//                       "is_read": true
//                   ]
//               } else {
//                   return [:]
//               }
//            }
//
//            self.database.child("\(conversationId)/messages").setValue(newMessages) { error, _ in
//
//                return
//            }
//
//            return
//        }
//    }

    //MARK: - DatabaseError -

    public enum DatabaseError: Error {
        case fetchUsersError
        case fetchConversationsError
    }
}

extension String {
    var toDatabaseFormat: String {
        replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
    }
}
