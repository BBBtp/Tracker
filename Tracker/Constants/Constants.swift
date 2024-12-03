//
//  Constants.swift
//  Tracker
//
//  Created by Богдан Топорин on 10.11.2024.
//

import Foundation
import UIKit

enum Constants {
    static let colors: [UIColor] = [.ypColor1, .ypColor2, .ypColor3, .ypColor4, .ypColor5, .ypColor6,
                                    .ypColor7, .ypColor8, .ypColor9, .ypColor10, .ypColor11, .ypColor12,
                                    .ypColor13, .ypColor14, .ypColor15, .ypColor16, .ypColor17, .ypColor18]

    static let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    static let allDays: Set<WeekDay> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    static let weekDays: Set<WeekDay> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let weekend: Set<WeekDay> = [.saturday, .sunday]
    
    static let stateKey: String = "hasSeenOnboarding"
}
