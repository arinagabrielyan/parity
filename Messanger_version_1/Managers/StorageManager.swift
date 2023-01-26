//
//  StorageManager.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 12.01.23.
//

import FirebaseStorage
import Foundation
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()

    public func deleteData(from fileName: String, completion: @escaping ((Bool) -> Void)) {
        storage.child("images/\(fileName)").delete { error in
            if let error {
                debugPrint(#function, error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    public func uploadProfileImage(
        with data: Data,
        fileName: String,
        compeletion: @escaping ((Result<String, Error>) -> Void)
    ) {
        storage.child("images/\(fileName)").putData(data) { _, error in
            if error != nil {
                compeletion(.failure(StorageError.failedToUploadImage))
            }

            self.storage.child("images/\(fileName)").downloadURL { url, error in
                if let url {
                    compeletion(.success(url.absoluteString))
                } else {
                    compeletion(.failure(StorageError.failedToDownloadUrl))
                }
            }
        }
    }

    public func downloadURL(with path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child("images/\(path)")

        reference.downloadURL(completion: { url, error in
            if let url {
                completion(.success(url))
            } else if let error {
                completion(.failure(error))
            }
        })
    }
}

extension StorageManager {
    enum StorageError: Error {
        case failedToUploadImage
        case failedToDownloadUrl
    }
}
