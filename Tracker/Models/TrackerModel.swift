//
//  TrackerModel.swift
//  Tracker
//
//  Created by Богдан Топорин on 29.10.2024.
//

import Foundation
import UIKit

struct TrackerModel {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let timeTable: [WeekDay]
    let type: TrackerType 
}
