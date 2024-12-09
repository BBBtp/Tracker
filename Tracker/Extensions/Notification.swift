//
//  Notification.swift
//  Tracker
//
//  Created by Богдан Топорин on 05.12.2024.
//

import Foundation

extension Notification.Name {
    static let trackerCompletionUpdated = Notification.Name("trackerCompletionUpdated")
}

extension Date {
    var dayStart: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
