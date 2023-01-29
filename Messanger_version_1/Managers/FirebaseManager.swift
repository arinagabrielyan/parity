//
//  FirebaseManager.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 08.01.23.
//

import FirebaseAuth

final class FirebaseManager {
    static func register(
        email: String,
        password: String,
        completion: @escaping ((Result<Bool, Error>) -> Void)
    ) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    static func login(
        email: String,
        password: String,
        completion: @escaping ((Result<Bool, Error>) -> Void)
    ) {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    static func resetPassword(email: String, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    static func signout() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch let error {
            debugPrint(#function + error.localizedDescription)
        }
    }

    static var isUserExist: Bool {
        guard let _ = FirebaseAuth.Auth.auth().currentUser else { return false }

        return true
    }
}
