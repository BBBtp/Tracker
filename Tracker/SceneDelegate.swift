//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Богдан Топорин on 14.10.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var stateStorage = StateStorage()
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        if shouldShowOnboarding() {
            window?.rootViewController = OnboardingViewController()
        } else {
            window?.rootViewController = TabBarConfigurator().setupTabBarController()
        }
        window?.makeKeyAndVisible()
    }
    
    private func shouldShowOnboarding() -> Bool {
        return !stateStorage.viewState
    }

}

