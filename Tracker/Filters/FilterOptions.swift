//
//  FilterOptions.swift
//  Tracker
//
//  Created by Богдан Топорин on 04.12.2024.
//

import Foundation

enum FilterOptions: String, CaseIterable {
    case all = "All trackers"
    case today = "Trackers for current day"
    case completed = "Completed"
    case uncompleted = "Uncompleted"

    var localizedTitle: String {
        switch self {
        case .all:
            return NSLocalizedString("filterAllTitle", comment: "All trackers")
        case .today:
            return NSLocalizedString("filterTodayTitle", comment: "Trackers for current day")
        case .completed:
            return NSLocalizedString("filterCompletedTitle", comment: "Completed")
        case .uncompleted:
            return NSLocalizedString("filterUncompletedTitle", comment: "Uncompleted")
        }
    }
}

