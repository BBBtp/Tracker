//
//  TrackerStore.swift
//  Tracker
//
//  Created by Богдан Топорин on 09.11.2024.
//

import Foundation
import CoreData
import UIKit
struct TrackerStoreUpdate {
    let insertedSections: [Int]
    let deletedSections: [Int]
    let insertedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
    let updatedIndexes: [IndexPath]
    let movedIndexes: [(from: IndexPath, to: IndexPath)]
}

struct TrackerCompletion {
    let tracker: TrackerModel
    let numberOfCompletions: Int
    let isCompleted: Bool
    let isPinned: Bool
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorTransformer()
    private let uiWeekDayMarshalling = WeekDayArrayTransformer()
    weak var delegate: TrackerStoreDelegate?
    private var date: Date
    private var insertedSections: [Int] = []
    private var deletedSections: [Int] = []
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    private var updatedIndexes: [IndexPath] = []
    private var movedIndexes: [(from: IndexPath, to: IndexPath)] = []
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {
        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true),
                                        NSSortDescriptor(key: "category.title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    convenience init(for date: Date) {
        let context = CoreDataManager.shared.context
        self.init(context: context, for: date)
    }
        
    init(context: NSManagedObjectContext, for date: Date) {
            self.context = context
            self.date = date
        }
//MARK: - Public methods
    func addTracker(category: String, tracker: TrackerModel) {
        do {
            try addTrackerToCoreData(to: category, tracker: tracker)
        } catch {
            print("Ошибка при добавлении трекера: \(error)")
        }
    }
    
    func updateTracker(in category: String, updatedTracker: TrackerModel) {
        do{
            try updateTrackerInCoreData(in: category, updatedTracker: updatedTracker)
        } catch {
            print("Ошибка при изменении трекера: \(error)")
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        do{
            try deleteTrackerFromCoreData(at: indexPath)
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }
    }

    public func pinTracker(at indexPath: IndexPath) {
        do {
            try pinTrackerToCoreData(at: indexPath)
        } catch {
            print("Ошибка при закреплении трекера: \(error)")
        }
    }

    public func unpinTracker(at indexPath: IndexPath) {
        do {
            try unpinTrackerFromCoreData(at: indexPath)
        } catch {
            print("Ошибка при откреплении трекера: \(error)")
        }
    }
    
    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion {
            let trackerCD = fetchedResultsController.object(at: indexPath)
            return createTrackerCompletion(from: trackerCD)
        }
    
    func updateDate(_ newDate: Date,_ searchText: String) {
        date = newDate
        fetchedResultsController.fetchRequest.predicate = fetchPredicate(searchText: searchText)
           try? fetchedResultsController.performFetch()
   }
    
    func changeCompletion(for indexPath: IndexPath, to isCompleted: Bool) {
            let trackerCoreData = fetchedResultsController.object(at: indexPath)
            do {
                try updateCompletionStatus(for: trackerCoreData, to: isCompleted)
            } catch {
                print("Ошибка при изменении статуса завершения: \(error)")
            }
        }
    func trackerType(at indexPath: IndexPath) -> Bool {
        let trackerData = fetchedResultsController.object(at: indexPath)
        return trackerData.type == 1 ? true : false
    }
    
    func categoryName(for indexPath: IndexPath) -> String {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerCoreData.category?.title ?? ""
    }
    
    
//MARK: - Private CoreData methods
    private func addTrackerToCoreData(to category: String, tracker: TrackerModel) throws {
        let categoryEntity = try fetchOrAddCategory(category)
        let newTracker = TrackerCD(context: context)
        newTracker.id = tracker.id
        newTracker.title = tracker.title
        newTracker.type = tracker.type == .habit ? 1 : 2
        newTracker.emoji = tracker.emoji
        newTracker.color = uiColorMarshalling.ColorToString(from: tracker.color)
        newTracker.timeTable = uiWeekDayMarshalling.WeekDayArrayToString(tracker.timeTable)
        newTracker.category = categoryEntity
        
        categoryEntity.addToTrackers(newTracker)
        try context.save()
    }
    private func updateTrackerInCoreData(in category: String, updatedTracker: TrackerModel) throws {
        
            let categoryEntity = try fetchOrAddCategory(category)
        guard let trackerCD = fetchTrackerByID(updatedTracker.id)
        else {
                throw NSError(domain: "TrackerStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found in the specified category."])
            }

            trackerCD.title = updatedTracker.title
            trackerCD.type = updatedTracker.type == .habit ? 1 : 2
            trackerCD.emoji = updatedTracker.emoji
            trackerCD.color = uiColorMarshalling.ColorToString(from: updatedTracker.color)
            trackerCD.timeTable = uiWeekDayMarshalling.WeekDayArrayToString(updatedTracker.timeTable)
            trackerCD.category = categoryEntity
            
            categoryEntity.addToTrackers(trackerCD)
            try context.save()
        }
    
    private func pinTrackerToCoreData(at indexPath: IndexPath) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let category = trackerCoreData.category, !category.isSelected else { return }
        
        let pinnedCategory = TrackerCategoryStore().fetchOrCreatePinnedCategory()
        
        trackerCoreData.categoryBeforePin = trackerCoreData.category
        trackerCoreData.category = pinnedCategory
        
        try context.save()
    }

   
    private func unpinTrackerFromCoreData(at indexPath: IndexPath) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let _ = trackerCoreData.categoryBeforePin else { return }
        
        trackerCoreData.category = trackerCoreData.categoryBeforePin
        trackerCoreData.categoryBeforePin = nil
        
        try context.save()
    }
    
    private func deleteTrackerFromCoreData(at indexPath: IndexPath) throws {
        let trackerData = fetchedResultsController.object(at: indexPath)
        context.delete(trackerData)
        try context.save()
    }
    private func fetchTrackerByID(_ id: UUID) -> TrackerCD? {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        return try? context.fetch(fetchRequest).first
    }
    
    private func fetchOrAddCategory(_ title: String) throws -> TrackerCategoryCD {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        let categories = try context.fetch(fetchRequest)
        if let existingCategory = categories.first {
            return existingCategory
        } else {
            let newCategory = TrackerCategoryCD(context: context)
            newCategory.title = title
            try context.save()
            return newCategory
        }
    }
    

    private func createTrackerCompletion(from trackerCD: TrackerCD) -> TrackerCompletion {
            let color = uiColorMarshalling.stringToColor(from: trackerCD.color ?? "")
            let weekDays = uiWeekDayMarshalling.StringToWeekDayArray(trackerCD.timeTable ?? "")
            
            let tracker = TrackerModel(
                id: trackerCD.id ?? UUID(),
                title: trackerCD.title ?? "",
                color: color,
                emoji: trackerCD.emoji ?? "",
                timeTable: weekDays,
                type: trackerCD.type == 1 ? .habit : .irregularEvent
            )
            
            let isCompleted = trackerCD.records?.contains { record in
                guard let trackerRecord = record as? TrackerRecordCD,
                      let trackerDate = trackerRecord.date else { return false }
                return Calendar.current.isDate(trackerDate, inSameDayAs: date)
            } ?? false
            
            return TrackerCompletion(
                tracker: tracker,
                numberOfCompletions: trackerCD.records?.count ?? 0,
                isCompleted: isCompleted,
                isPinned: trackerCD.category?.isSelected ?? false
            )
        }
    
    private func fetchPredicate(searchText: String) -> NSPredicate {
        let weekday = WeekDay.from(date: date)
        let weekdayString = weekday.map { String($0.rawValue) } ?? ""
        
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        let timeTablePredicate = NSPredicate(
            format: "(%K CONTAINS[n] %@) OR (%K == %@ AND (SUBQUERY(%K, $record, $record != nil AND $record.date == %@).@count > 0 OR SUBQUERY(%K, $record, $record != nil).@count == 0))",
            #keyPath(TrackerCD.timeTable),
            weekdayString,
            #keyPath(TrackerCD.timeTable),
            "",
            #keyPath(TrackerCD.records),
            date as NSDate,
            #keyPath(TrackerCD.records)
        )
        return NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, timeTablePredicate])
    }
    
    private func updateCompletionStatus(for trackerCoreData: TrackerCD, to isCompleted: Bool) throws {
            let existingRecord = trackerCoreData.records?.first { record in
                guard let trackerRecord = record as? TrackerRecordCD,
                      let trackerDate = trackerRecord.date else {
                    return false
                }
                return Calendar.current.isDate(trackerDate, inSameDayAs: date)
            }
            
            if isCompleted, existingRecord == nil {
                let trackerRecordCoreData = TrackerRecordCD(context: context)
                trackerRecordCoreData.date = date
                trackerRecordCoreData.trackerRecords = trackerCoreData
                trackerRecordCoreData.id = trackerCoreData.id
                try context.save()
            } else if !isCompleted, let trackerRecordCoreData = existingRecord as? TrackerRecordCD {
                context.delete(trackerRecordCoreData)
                try context.save()
            }
        }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    var isEmpty: Bool {
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                return fetchedObjects.isEmpty
            } else {
                return true
            }
        }
        
        func sectionName(for section: Int) -> String {
            return fetchedResultsController.sections?[section].name ?? ""
        }
        
        var numberOfSections: Int {
            fetchedResultsController.sections?.count ?? 0
        }
        
        func numberOfItemsInSection(_ section: Int) -> Int {
            fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            insertedSections.removeAll()
            deletedSections.removeAll()
            insertedIndexes.removeAll()
            deletedIndexes.removeAll()
            updatedIndexes.removeAll()
            movedIndexes.removeAll()
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange sectionInfo: NSFetchedResultsSectionInfo,
                        atSectionIndex sectionIndex: Int,
                        for type: NSFetchedResultsChangeType) {
            switch type {
            case .insert:
                insertedSections.append(sectionIndex)
            case .delete:
                deletedSections.append(sectionIndex)
            default:
                break
            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange anObject: Any,
                        at indexPath: IndexPath?,
                        for type: NSFetchedResultsChangeType,
                        newIndexPath: IndexPath?) {
            switch type {
            case .delete:
                if let indexPath {
                    deletedIndexes.append(indexPath)
                }
            case .insert:
                if let newIndexPath {
                    insertedIndexes.append(newIndexPath)
                }
            case .update:
                if let indexPath {
                    updatedIndexes.append(indexPath)
                }
            case .move:
                if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                    movedIndexes.append((from: oldIndexPath, to: newIndexPath))
                }
            @unknown default:
                break
            }
        }
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            let update = TrackerStoreUpdate(
                insertedSections: insertedSections,
                deletedSections: deletedSections,
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes,
                movedIndexes: movedIndexes
            )
            delegate?.didUpdate(update)
        }
}
