//
//  MainScreen.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 14.01.23.
//

import UIKit

// Need for Localization
public var controllers: [UIViewController] = []

class MainScreen: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)

        guard let viewControllers = self.viewControllers else { return }

        controllers = viewControllers.compactMap { ($0 as? UINavigationController)?.viewControllers.first }
        controllers.forEach { ($0 as? Localizable)?.updateLocalization() }
    }
}
