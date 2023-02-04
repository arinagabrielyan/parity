//
//  Localize.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 02.02.23.
//

protocol Localizable {
    func updateLocalization()
}

class Localize {
    enum Language {
        case en
        case rus
    }
    static var language: Language = .en

    static func update(language: Language) {
        switch language {
            case .en:
                Localize.language = .en
            case .rus:
                Localize.language = .rus
        }
    }
}

class LocalizeStrings {
    class var privateNote: String { Localize.language == .en ? "Private Note" : "Частная заметка" }
    class var username: String { Localize.language == .en ? "Username" : "Имя пользователя" }
    class var language: String { Localize.language == .en ? "Language" : "Язык" }
    class var account: String { Localize.language == .en ? "Account" : "Аккаунт" }
    class var logout: String { Localize.language == .en ? "Log out" : "Выйти" }
    class var useres: String { Localize.language == .en ? "Users" : "Пользователи" }
    class var save: String { Localize.language == .en ? "Save" : "Сохранить" }
    class var chat: String { Localize.language == .en ? "Chat" : "Чат" }
    class var takePhoto: String { Localize.language == .en ? "Take Photo" : "Фотографировать" }
    class var choosePhoto: String { Localize.language == .en ? "Choose Photo" : "Выбрать фото" }
    class var cancel: String { Localize.language == .en ? "Cancel" : "Отмена" }
    class var newNote: String { Localize.language == .en ? "New Note" : "Новая заметка" }
    class var unlock: String { Localize.language == .en ? "Unlock" : "Разблокировать" }
    class var profile: String { Localize.language == .en ? "Profile" : "Профиль" }
    class var update: String { Localize.language == .en ? "Update" : "Обновить" }
    class var profilePicture: String { Localize.language == .en ? "Profile Picture" : "Изображение профиля" }
    class var profilePictureMessage: String { Localize.language == .en ? "How would you like to select picture?" : "Как бы вы хотели выбрать картинку?" }
    class var chechFaceID: String { Localize.language == .en ? "Check Face ID for access to Private Notes?" : "Проверьте Face ID для доступа к личным заметкам" }
    // must add
}
