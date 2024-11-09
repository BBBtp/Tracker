//
//  TrackerStore.swift
//  Tracker
//
//  Created by Богдан Топорин on 09.11.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorTransformer()
    private let uiWeekDayMarshalling = WeekDayArrayTransformer()
    convenience init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addTracker(to category: TrackerCategoryModel, tracker: TrackerModel, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let categories = try context.fetch(fetchRequest)
            var categoryEntity: TrackerCategoryCD
            
            if let existingCategory = categories.first {
                categoryEntity = existingCategory
            } else {
                categoryEntity = TrackerCategoryCD(context: context)
                categoryEntity.title = category.title
            }
            
            let newTracker = TrackerCD(context: context)
            newTracker.id = tracker.id
            newTracker.title = tracker.title
            newTracker.type = tracker.type == .habit ? 1 : 2
            newTracker.color = uiColorMarshalling.ColorToString(from: tracker.color)
            newTracker.timeTable = uiWeekDayMarshalling.WeekDayArrayToString(tracker.timeTable)
            
            newTracker.category = categoryEntity
            categoryEntity.addToTrackers(newTracker)
            
            
            CoreDataManager.shared.saveContext()
            
            completion(true)
        } catch {
            print("Error adding tracker: \(error)")
            completion(false)
        }
    }
    
    func fetchTrackers(completion: @escaping ([TrackerModel]) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        
        do {
            let trackersFromCoreData = try context.fetch(fetchRequest)
            let trackers: [TrackerModel] = trackersFromCoreData.compactMap { tracker in
                guard
                    let colorString = tracker.color,
                    let timetableString = tracker.timeTable
                else {
                    return nil
                }
                let color = uiColorMarshalling.stringToColor(from: colorString)
                let weekDays = uiWeekDayMarshalling.StringToWeekDayArray(timetableString)
                return TrackerModel(
                    id: tracker.id ?? UUID(),
                    title: tracker.title ?? "",
                    color: color,
                    emoji: tracker.emoji ?? "",
                    timeTable: weekDays,
                    type: tracker.type == 1 ? .habit : .irregularEvent
                )
            }
            completion(trackers)
        } catch {
            print("Failed to fetch trackers: \(error)")
            completion([])
        }
    }

}
