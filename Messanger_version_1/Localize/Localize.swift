//
//  Localize.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 02.02.23.
//

class Loci {
    enum Language {
        case en
        case rus
    }
    static var lang: Language = .en

    static func update(language: Language) {
        switch language {
            case .en:
                Loci.lang = .en
            case .rus:
                Loci.lang = .rus
        }
    }

    deinit {
        
    }
}

class Localize {
    class var username: String { Loci.lang == .en ? "Username" : "Имя пользователя" }
    class var language: String { Loci.lang == .en ? "Language" : "Язык" }
    class var account: String { Loci.lang == .en ? "Account" : "Аккаунт" }
    class var logout: String { Loci.lang == .en ? "Log out" : "Выйти" }
    class var useres: String { Loci.lang == .en ? "Users" : "Пользователи" }
    class var save: String { Loci.lang == .en ? "Save" : "Сохранить" }
    // must add
}