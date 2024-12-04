//
//  UIColor.swift
//  Tracker
//
//  Created by Богдан Топорин on 04.12.2024.
//

import Foundation
import UIKit

extension UIColor {
    func isEqualTo(_ color: UIColor) -> Bool {
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0

        self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return red1 == red2 && green1 == green2 && blue1 == blue2 && alpha1 == alpha2
    }
}
