//
//  ModeManager.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 14.02.23.
//

import UIKit

class ModeManager {
    public static var mode: Mode = .light

    public enum Mode {
        case light
        case dark
    }

    static func update(mode: Mode) {
        self.mode = mode
    }
}

class AppColors {
    class var mainButton: UIColor { .link }
    class var blackAndWhite: UIColor { return (ModeManager.mode == .dark) ? .black : .white }
    class var mainColor: UIColor { return (ModeManager.mode == .dark) ? UIColor(named: "lightBlack")! : UIColor(named: "darkWhite")! }
    class var textColor: UIColor { return (ModeManager.mode == .dark) ? .white : .black }
    class var tintLinkAndBlack: UIColor { return (ModeManager.mode == .dark) ? .link : .black }
    class var placeholderColor: UIColor { return (ModeManager.mode == .dark) ? .link.withAlphaComponent(0.6) : .lightGray }
    class var red: UIColor { .red }
}
