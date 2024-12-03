//
//  UIViewController+NavBar.swift
//  Tracker
//
//  Created by Богдан Топорин on 03.12.2024.
//

import Foundation
import UIKit

extension UIViewController {
    func setupNavigationBar(title: String, hidesBackButton: Bool = true) {
        self.title = title
        navigationItem.hidesBackButton = hidesBackButton
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
    }
}
