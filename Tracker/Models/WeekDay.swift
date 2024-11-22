
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
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    var shortText: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
