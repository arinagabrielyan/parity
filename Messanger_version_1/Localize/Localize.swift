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
    class var password: String { Localize.language == .en ? "Password" : "Пароль" }
    class var forgotPassword: String { Localize.language == .en ? "Forgot password?" : "Забыли пароль?" }
    class var restorePassword: String { Localize.language == .en ? "Restore password" : "Восстановить пароль" }
    class var searchUser: String { Localize.language == .en ? "Search User..." : "Поиск пользователя..." }
    class var register: String { Localize.language == .en ? "Register" : "Зарегистрироваться" }
    class var registration: String { Localize.language == .en ? "Registration" : "Регистрация" }
    class var username: String { Localize.language == .en ? "Username" : "Имя пользователя" }
    class var language: String { Localize.language == .en ? "Language" : "Язык" }
    class var account: String { Localize.language == .en ? "Account" : "Аккаунт" }
    class var logout: String { Localize.language == .en ? "Log out" : "Выйти" }
    class var login: String { Localize.language == .en ? "Log in" : "Войти" }
    class var save: String { Localize.language == .en ? "Save" : "Сохранить" }
    class var chat: String { Localize.language == .en ? "Chat" : "Чат" }
    class var useres: String { Localize.language == .en ? "Users" : "Пользователи" }
    class var takePhoto: String { Localize.language == .en ? "Take Photo" : "Фотографировать" }
    class var choosePhoto: String { Localize.language == .en ? "Choose Photo" : "Выбрать фото" }
    class var cancel: String { Localize.language == .en ? "Cancel" : "Отмена" }
    class var newNote: String { Localize.language == .en ? "New Note" : "Новая заметка" }
    class var send: String { Localize.language == .en ? "Send" : "Отправить" }
    class var unlock: String { Localize.language == .en ? "Unlock" : "Разблокировать" }
    class var profile: String { Localize.language == .en ? "Profile" : "Профиль" }
    class var mode: String { Localize.language == .en ? "Mode" : "Тема" }
    class var type: String { Localize.language == .en ? "Type..." : "Пиши..." }
    class var update: String { Localize.language == .en ? "Update" : "Обновить" }
    class var userNotFound: String { Localize.language == .en ? "User not found" : "Пользователь не найден" }
    class var camera: String { Localize.language == .en ? "Camera" : "Камера" }
    class var photoLibrary: String { Localize.language == .en ? "Photo Library" : "Библиотека фотографий" }
    class var sendLink: String { Localize.language == .en ? "Link will be send to your email" : "Ссылка будет отправлена на вашу почту" }
    class var profilePicture: String { Localize.language == .en ? "Profile Picture" : "Изображение профиля" }
    class var profilePictureMessage: String { Localize.language == .en ? "How would you like to select picture?" : "Как бы вы хотели выбрать картинку?" }
    class var chechFaceID: String { Localize.language == .en ? "Check Face ID for access to Private Notes?" : "Проверьте Face ID для доступа к личным заметкам" }
    class var noConversationYet: String { Localize.language == .en ? "No conversation yet" : "Чатов пока нет" }
    // must add
}
