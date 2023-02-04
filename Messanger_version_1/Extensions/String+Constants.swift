//
//  String+Constants.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 08.01.23.
//

extension String {
    var toDatabaseFormat: String {
        replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
    }
}
