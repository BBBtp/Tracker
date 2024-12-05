import UIKit
import Foundation

protocol StatisticsServiceProtocol {
    var numberOfCompleted: Int { get }
    var bestStreak: Int { get }
    var perfectDays: Int { get }
    var averageCompletion: Int { get }
    
    func onTrackerCompletion(for date: Date)
    func onTrackerUnCompletion(for date: Date)
}

final class StatisticsService: StatisticsServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let calendar = Calendar.current

    private enum Keys: String {
        case numberOfCompleted
        case completionDates
        case bestStreak
        case perfectDays
    }

    private(set) var numberOfCompleted: Int {
        get { userDefaults.integer(forKey: Keys.numberOfCompleted.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.numberOfCompleted.rawValue) }
    }
    
    private var completionDates: [Date] {
        get {
            let data = userDefaults.data(forKey: Keys.completionDates.rawValue)
            return (try? JSONDecoder().decode([Date].self, from: data ?? Data())) ?? []
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            userDefaults.set(data, forKey: Keys.completionDates.rawValue)
        }
    }
    
    private(set) var bestStreak: Int {
        get { userDefaults.integer(forKey: Keys.bestStreak.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.bestStreak.rawValue) }
    }
    
    private(set) var perfectDays: Int {
        get { userDefaults.integer(forKey: Keys.perfectDays.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.perfectDays.rawValue) }
    }
    
    var averageCompletion: Int {
        guard !completionDates.isEmpty else { return 0 }
        return (numberOfCompleted) / (Set(completionDates).count)
    }
    
    func onTrackerCompletion(for date: Date) {
        numberOfCompleted += 1
        completionDates.append(date)
        updateBestStreak()
        updatePerfectDays()
    }
    
    func onTrackerUnCompletion(for date: Date) {
        guard numberOfCompleted > 0 else { return }
        numberOfCompleted -= 1
        if let index = completionDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            completionDates.remove(at: index)
        }
        updateBestStreak()
        updatePerfectDays()
    }
    
    private func updateBestStreak() {
        let sortedDates = Set(completionDates).sorted()
        var currentStreak = 0
        var maxStreak = 0
        
        for (index, date) in sortedDates.enumerated() {
            if index == 0 || calendar.isDate(date, equalTo: sortedDates[index - 1], toGranularity: .day) {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        bestStreak = maxStreak
    }
    
    private func updatePerfectDays() {
        let groupedByDay = Dictionary(grouping: completionDates, by: { calendar.startOfDay(for: $0) })
        let totalTrackersPerDay = groupedByDay.mapValues { $0.count }
        perfectDays = totalTrackersPerDay.values.filter { $0 == 3 /* Количество трекеров в день (можно варьировать) */ }.count
    }
}
