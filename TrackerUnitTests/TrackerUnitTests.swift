//
//  TrackerUnitTests.swift
//  TrackerUnitTests
//
//  Created by Богдан Топорин on 05.12.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerUnitTests: XCTestCase {

    func testTrackers() throws {
        let store = TrackerStore()
        
        do {
            try store.deleteAll()
        } catch {
            XCTFail("Failed to clear Core Data: \(error.localizedDescription)")
            return
        }
        let category = "Test"
        
        let timeTable: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        let emptyTimeTable: [WeekDay] = []
        let regularTracker = TrackerModel(id: UUID(), title: "Regular", color: .ypColor1, emoji: "🥸", timeTable: timeTable, type: .habit)
        store.addTracker(category: category, tracker: regularTracker)
        
        let irregularTracker = TrackerModel(id: UUID(), title: "Irregular", color: .ypColor2, emoji: "🧐", timeTable: emptyTimeTable, type: .irregularEvent)
        store.addTracker(category: category, tracker: irregularTracker)
        
        let TabBarViewController = TabBarConfigurator().setupTabBarController()
        TabBarViewController.loadViewIfNeeded()
        
        assertSnapshot(of: TabBarViewController, as: .image(traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(of: TabBarViewController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

}
