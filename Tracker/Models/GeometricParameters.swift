//
//  GeometricParameters.swift
//  Tracker
//
//  Created by Богдан Топорин on 08.11.2024.
//

import Foundation
import UIKit

struct GeometricParameters {
    let cellCount: Int
    let leftInsets: CGFloat
    let rightInsets: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInsets: CGFloat, rightInsets: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInsets = leftInsets
        self.rightInsets = rightInsets
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInsets + rightInsets + CGFloat(cellCount - 1) * cellSpacing
    }
}
