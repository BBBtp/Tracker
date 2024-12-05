//
//  UITableVIew+Cell.swift
//  Tracker
//
//  Created by Богдан Топорин on 05.12.2024.
//

import Foundation
import UIKit

extension UITableViewCell {
    func applySeparator(in tableView: UITableView, with indexPath: IndexPath) {
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        // Настройка закругленных углов
        if indexPath.row == 0 {
            self.layer.cornerRadius = 16
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastRow {
            self.layer.cornerRadius = 16
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            self.layer.cornerRadius = 0
        }

        // Настройка отступов разделителя
        if isLastRow {
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
