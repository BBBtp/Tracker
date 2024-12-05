
//
//  WeekDay.swift
//  Tracker
//
//  Created by Богдан Топорин on 10.11.2024.
//
import Foundation
enum WeekDay: Int, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    static func from(date: Date) -> WeekDay? {
        let calendar = Calendar(identifier: .gregorian)
        let dayNum = calendar.component(.weekday, from: date)
        return WeekDay(rawValue: dayNum == 1 ? 7 : dayNum - 1)
    }
    var fullText: String {
        switch self {
        case .monday: return NSLocalizedString("mondayFull", comment: "Full name of Monday")
        case .tuesday: return NSLocalizedString("tuesdayFull", comment: "Full name of Tuesday")
        case .wednesday: return NSLocalizedString("wednesdayFull", comment: "Full name of Wednesday")
        case .thursday: return NSLocalizedString("thursdayFull", comment: "Full name of Thursday")
        case .friday: return NSLocalizedString("fridayFull", comment: "Full name of Friday")
        case .saturday: return NSLocalizedString("saturdayFull", comment: "Full name of Saturday")
        case .sunday: return NSLocalizedString("sundayFull", comment: "Full name of Sunday")
        }
    }

    var shortText: String {
        switch self {
        case .monday: return NSLocalizedString("mondayShort", comment: "Short name of Monday")
        case .tuesday: return NSLocalizedString("tuesdayShort", comment: "Short name of Tuesday")
        case .wednesday: return NSLocalizedString("wednesdayShort", comment: "Short name of Wednesday")
        case .thursday: return NSLocalizedString("thursdayShort", comment: "Short name of Thursday")
        case .friday: return NSLocalizedString("fridayShort", comment: "Short name of Friday")
        case .saturday: return NSLocalizedString("saturdayShort", comment: "Short name of Saturday")
        case .sunday: return NSLocalizedString("sundayShort", comment: "Short name of Sunday")
        }
    }

}
