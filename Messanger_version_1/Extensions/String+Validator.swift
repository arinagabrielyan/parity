//
//  String+Validator.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 14.01.23.
//

import Foundation

extension String {
    static func validator(_ email: String, _ password: String? = nil, username: String? = nil) -> Bool {

//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//        let passwordRegEx = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}"
//
//        let emialPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
//
//        return emialPred.evaluate(with: email) && passwordPred.evaluate(with: password)

        return true 
    }
}
