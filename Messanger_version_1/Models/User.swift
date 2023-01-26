//
//  User.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 08.01.23.
//

import UIKit

public struct User {
    let username: String
    let email: String
    var url: String = ""
 
    let lastMessage: String? = nil
    let image: UIImage? = nil

    var profileImageName: String {
        return "\(email.toDatabaseFormat)_profile_image.png"
    }
}
