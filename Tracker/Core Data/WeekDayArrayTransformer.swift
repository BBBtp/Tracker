//
//  WeekDayArrayTransformer.swift
//  Tracker
//
//  Created by Богдан Топорин on 09.11.2024.
//
import Foundation

class WeekDayArrayTransformer{
    func WeekDayArrayToString(_ value: [WeekDay]) -> String {
        return value.map {String($0.rawValue)}.joined(separator: ",")
    }
    
    func StringToWeekDayArray(_ value: String) -> [WeekDay] {
        return value.split(separator: ",").compactMap { rawValue in
            guard let intValue = Int(rawValue) else { return nil }
            return WeekDay(rawValue: intValue)
        }
    }

}
