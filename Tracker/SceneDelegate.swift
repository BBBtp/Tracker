//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Богдан Топорин on 14.10.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, 
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = setupTabBarController()
        window?.makeKeyAndVisible()
    }
    
    private func setupTabBarController() -> UITabBarController {
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
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    func sceneWillResignActive(_ scene: UIScene) {
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

