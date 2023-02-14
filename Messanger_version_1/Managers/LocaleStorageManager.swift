//
//  LocalStorageManager.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 24.01.23.
//

import Foundation

class LocaleStorageManager {
    private let userDefaultsStandard = UserDefaults.standard
    static let shared = LocaleStorageManager()

    var email: String? {
        get {
            userDefaultsStandard.value(forKey: "user_email") as? String
        }
        set {
            userDefaultsStandard.set(newValue, forKey: "user_email")
        }
    }

    var username: String? {
        get {
            userDefaultsStandard.value(forKey: "user_name") as? String
        }
        set {
            userDefaultsStandard.set(newValue, forKey: "user_name")
        }
    }

    var isEnglishLanguage: Bool? {
        get {
            userDefaultsStandard.value(forKey: "is_english") as? Bool
        }
        set {
            userDefaultsStandard.set(newValue, forKey: "is_english")
        }
    }

    var isDarkMode: Bool? {
        get {
            userDefaultsStandard.value(forKey: "is_dark_mode") as? Bool
        }
        set {
            userDefaultsStandard.set(newValue, forKey: "is_dark_mode")
        }
    }

    var profileImageUrl: String? {
        get {
            userDefaultsStandard.value(forKey: "profile_image_url") as? String
        }
        set {
            userDefaultsStandard.set(newValue, forKey: "profile_image_url")
        }
    }

    var profileImage: Data? {
        get {
            userDefaultsStandard.value(forKey: "profile_image") as? Data
        }
        set {
            userDefaultsStandard.set(newValue, forKey: "profile_image")
        }
    }

    private init() {}
}
