//
//  TabBarController.swift
//  
//
//  Created by Богдан Топорин on 30.08.2024.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        
        guard let trackerViewController = storyboard.instantiateViewController(
            withIdentifier: "trackerViewController"
        ) as? TrackersViewController else {
            fatalError("Could not instantiate TrackersViewController")
        }
        
       
        
        trackerViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Main Active"), selectedImage: nil)
        
        // Создаем экземпляр ProfileViewController и передаем презентер
        let statisticsViewController = StatisticsViewController()
      
        
        statisticsViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Profile Active"), selectedImage: nil)
        
        // Добавляем оба контроллера во вкладки
        self.viewControllers = [trackerViewController, statisticsViewController]
    }
}
