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
    private var statistic = StatisticsService()
    private var date: Date
    private var filter: FilterOptions
    private var insertedSections: [Int] = []
    private var deletedSections: [Int] = []
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    private var updatedIndexes: [IndexPath] = []
    private var movedIndexes: [(from: IndexPath, to: IndexPath)] = []
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {
        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.priority", ascending: true),
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)         
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        controller.delegate = self
        let trackers = try? context.fetch(fetchRequest)
        for tracker in trackers ?? [] {
            print("Tracker: \(tracker.title ?? "No title"), Category: \(tracker.category?.title ?? "No category")")
        }
        try? controller.performFetch()
        return controller
    }()
    
    convenience init(for date: Date,with filter: FilterOptions) {
        let context = CoreDataManager.shared.context
        self.init(context: context, for: date,with: filter)
    }
    
    init(context: NSManagedObjectContext, for date: Date, with filter: FilterOptions) {
        self.context = context
        self.date = date
        self.filter = filter
    }
    
    override init() {
        self.date = Date()
        self.filter = .all
        let context = CoreDataManager.shared.context
        self.context = context
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
    
    func pinTracker(at indexPath: IndexPath) {
        do {
            try pinTrackerToCoreData(at: indexPath)
        } catch {
            print("Ошибка при закреплении трекера: \(error)")
        }
    }
    
    func unpinTracker(at indexPath: IndexPath) {
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
    
    var isFilteredEmpty: Bool {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            return fetchedObjects.isEmpty
        } else {
            return true
        }
    }
    
    var isDateEmpty: Bool {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.predicate = allTrackersFetchPredicate()
        fetchRequest.fetchLimit = 1
        
        return (try? context.fetch(fetchRequest))?.isEmpty ?? true
    }
    
    func deleteAll() throws {
        let fetchRequestTrackers: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        let fetchRequestRecords: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        let fetchRequestCategories: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        
        let trackers = try context.fetch(fetchRequestTrackers)
        let records = try context.fetch(fetchRequestRecords)
        let categories = try context.fetch(fetchRequestCategories)
        
        trackers.forEach { context.delete($0) }
        records.forEach { context.delete($0) }
        categories.forEach { context.delete($0) }
        
        try context.save()
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
    
    private func fetchPredicate(with searchQuery: String? = nil) -> NSPredicate {
        switch filter {
        case .all, .today:
            return allTrackersFetchPredicate(with: searchQuery)
        case .completed:
            return completedTrackersFetchPredicate(with: searchQuery)
        case .uncompleted:
            return uncompletedTrackersFetchPredicate(with: searchQuery)
        }
    }
    
    private func allTrackersFetchPredicate(with searchQuery: String? = nil) -> NSPredicate {
        let weekday = WeekDay.from(date: date)
        let weekdayString = weekday.map { String($0.rawValue) } ?? ""
        
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchQuery ?? "")
        
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
        
        let finalPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, timeTablePredicate])
        
        guard let searchQuery else {
            return finalPredicate
        }
        
        return combinePredicateWithSearchQuery(predicate: finalPredicate, query: searchQuery)
    }
    
    private func completedTrackersFetchPredicate(with searchQuery: String?) -> NSPredicate {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        // Предикат для завершенных трекеров на указанную дату
        let completedAtDatePredicate = NSPredicate(
            format: "SUBQUERY(%K, $record, $record.date >= %@ AND $record.date < %@).@count > 0",
            #keyPath(TrackerCD.records), startOfDay as NSDate, endOfDay as NSDate
        )

        // Финальный предикат
        guard let searchQuery else {
            return completedAtDatePredicate
        }

        return combinePredicateWithSearchQuery(predicate: completedAtDatePredicate, query: searchQuery)
    }

    
    private func uncompletedTrackersFetchPredicate(with searchQuery: String?) -> NSPredicate {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        // Проверка на невыполненные записи
        let notCompletedAtDatePredicate = NSPredicate(
            format: "SUBQUERY(%K, $record, $record.date >= %@ AND $record.date < %@).@count == 0",
            #keyPath(TrackerCD.records), startOfDay as NSDate, endOfDay as NSDate
        )

        let weekday = WeekDay.from(date: date)
        let weekdayString = weekday.map { String($0.rawValue) } ?? ""

        // Проверка на соответствие расписанию
        let schedulePredicate = NSPredicate(
            format: "%K CONTAINS[n] %@",
            #keyPath(TrackerCD.timeTable), weekdayString
        )

        let isNotCompletedRegular = NSCompoundPredicate(
            andPredicateWithSubpredicates: [notCompletedAtDatePredicate, schedulePredicate]
        )

        // Проверка на нерегулярные трекеры
        let isIrregular = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCD.type), ""
        )

        let isNotCompletedIrregular = NSPredicate(
            format: "SUBQUERY(%K, $record, $record.date >= %@ AND $record.date < %@).@count == 0",
            #keyPath(TrackerCD.records), startOfDay as NSDate, endOfDay as NSDate
        )

        // Финальный предикат
        let finalPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [isNotCompletedRegular, isIrregular, isNotCompletedIrregular]
        )

        guard let searchQuery else {
            return finalPredicate
        }

        return combinePredicateWithSearchQuery(predicate: finalPredicate, query: searchQuery)
    }


    
    private func combinePredicateWithSearchQuery(predicate: NSPredicate, query: String) -> NSPredicate {
        let searchPredicate = NSPredicate(
            format: "%K CONTAINS[c] %@",
            #keyPath(TrackerCD.title),
            query
        )
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, searchPredicate])
    }
    
    func applyFilter(_ filter: FilterOptions, on date: Date, with searchQuery: String?) {
        self.filter = filter
        self.date = date
        
        fetchedResultsController.fetchRequest.predicate = fetchPredicate(with: searchQuery)
        try? fetchedResultsController.performFetch()
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
            statistic.onTrackerCompletion(for: date)
            try context.save()
        } else if !isCompleted, let trackerRecordCoreData = existingRecord as? TrackerRecordCD {
            statistic.onTrackerUnCompletion(for: date)
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
