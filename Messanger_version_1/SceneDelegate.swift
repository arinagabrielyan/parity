//
//  SceneDelegate.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 07.01.23.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }
        
        if FirebaseManager.isUserExist {
            ImageDownloader.downloadProfileImage()

            let mainScreen = UIStoryboard.main.instantiateViewController(withIdentifier: "MainScreen") as! MainScreen
            self.window?.rootViewController = mainScreen

            guard let isEnglishLanguage = LocaleStorageManager.shared.isEnglishLanguage else {
                Localize.update(language: .en)
                return
            }
            
            isEnglishLanguage ? Localize.update(language: .en) : Localize.update(language: .rus)

            guard let isDarkMode = LocaleStorageManager.shared.isDarkMode else {
                ModeManager.update(mode: .light)
                return
            }

            isDarkMode ? ModeManager.update(mode: .dark) : ModeManager.update(mode: .light)

        } else {
            let authNavigationController = UIStoryboard.main.instantiateViewController(withIdentifier: "AuthNavigationController") as! AuthNavigationController

            Localize.update(language: .en)
            ModeManager.update(mode: .light)
            
            self.window?.rootViewController = authNavigationController
        }
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
