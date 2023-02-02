//
//  MainScreen.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 14.01.23.
//

import UIKit

public var controllers: [UIViewController] = []

public var taps: [UIViewController] = []

class MainScreen: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)

        guard let viewControllers = self.viewControllers else { return }

        controllers = viewControllers
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
}
