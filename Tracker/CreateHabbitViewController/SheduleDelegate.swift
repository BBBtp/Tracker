//
//  CreateHabbitDelegate.swift
//  Tracker
//
//  Created by Богдан Топорин on 31.10.2024.
//

import Foundation
import UIKit

protocol SheduleDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
}
