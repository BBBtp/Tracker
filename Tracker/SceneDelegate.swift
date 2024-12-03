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
            window?.rootViewController = setupTabBarController()
        }
        window?.makeKeyAndVisible()
    }
    
    private func shouldShowOnboarding() -> Bool {
        return !stateStorage.viewState
        }
    func setupTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        let trackerViewController = TrackersViewController()
        trackerViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "trackers"), selectedImage: nil)
        let trackerNavController = UINavigationController(rootViewController: trackerViewController)
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "stats"), selectedImage: nil)
        let statisticsNavController = UINavigationController(rootViewController: statisticsViewController)
        tabBarController.viewControllers = [trackerNavController, statisticsNavController]
        return tabBarController
    }
}

