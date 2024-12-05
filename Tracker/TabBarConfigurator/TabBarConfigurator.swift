//
//  TabBarConfigurator.swift
//  Tracker
//
//  Created by Богдан Топорин on 05.12.2024.
//

import Foundation
import UIKit

final class TabBarConfigurator {
    func setupTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let trackerViewController = TrackersViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackersTabBarTitle", comment: "Trackers Title"),
            image: UIImage(named: "trackers"),
            selectedImage: nil
        )
        let trackerNavController = UINavigationController(rootViewController: trackerViewController)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statisticsTabBarTitle", comment: "Statistics tracker"),
            image: UIImage(named: "stats"),
            selectedImage: nil
        )
        let statisticsNavController = UINavigationController(rootViewController: statisticsViewController)
        
        tabBarController.viewControllers = [trackerNavController, statisticsNavController]
        tabBarController.tabBar.barTintColor = .ypWhite
        
        trackerNavController.navigationBar.barTintColor = .ypWhite
        statisticsNavController.navigationBar.barTintColor = .ypWhite
        
        return tabBarController
    }
    
}
