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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true), NSSortDescriptor(key: "category.title", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category.title", cacheName: nil)
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    convenience init(for date: Date) {
        self.init(context: CoreDataManager.shared.context, for: date)
    }
    
    init(context: NSManagedObjectContext, for date: Date) {
        self.context = context
        self.date = date
    }
    
    func addTracker(to category: TrackerCategoryModel, tracker: TrackerModel) {
        let categoryEntity = fetchOrAddCategory(category.title)
        let newTracker = TrackerCD(context: context)
        newTracker.id = tracker.id
        newTracker.title = tracker.title
        newTracker.type = tracker.type == .habit ? 1 : 2
        newTracker.emoji = tracker.emoji
        newTracker.color = uiColorMarshalling.ColorToString(from: tracker.color)
        newTracker.timeTable = uiWeekDayMarshalling.WeekDayArrayToString(tracker.timeTable)
        newTracker.category = categoryEntity
        categoryEntity.addToTrackers(newTracker)
        try? context.save()
    }

    func fetchOrAddCategory(_ title: String) -> TrackerCategoryCD {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        do {
            let categories = try context.fetch(fetchRequest)
            if let existingCategory = categories.first {
                return existingCategory
            } else {
                let newCategory = TrackerCategoryCD(context: context)
                newCategory.title = title
                try context.save()
                return newCategory
            }
        } catch {
            print("Ошибка при попытке найти или добавить категорию: \(error)")
            return TrackerCategoryCD()
        }
    }

    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion {
        let trackerCD = fetchedResultsController.object(at: indexPath)
        let color = uiColorMarshalling.stringToColor(from: trackerCD.color ?? "")
        let weekDays = uiWeekDayMarshalling.StringToWeekDayArray(trackerCD.timeTable ?? "")
        let tracker = TrackerModel(id: trackerCD.id ?? UUID(), title: trackerCD.title ?? "", color: color, emoji: trackerCD.emoji ?? "", timeTable: weekDays, type: trackerCD.type == 1 ? .habit : .irregularEvent)
        let isCompleted = trackerCD.records?.contains { record in
            guard let trackerRecord = record as? TrackerRecordCD, let trackerDate = trackerRecord.date else { return false }
            return Calendar.current.isDate(trackerDate, inSameDayAs: date)
        } ?? false
        return TrackerCompletion(tracker: tracker, numberOfCompletions: trackerCD.records?.count ?? 0, isCompleted: isCompleted)
    }

    func fetchPredicate(searchText: String) -> NSPredicate {
        let weekday = WeekDay.from(date: date)
        let weekdayString = weekday.map { String($0.rawValue) } ?? ""
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        let timeTablePredicate: NSPredicate
        
        guard let trackerCD = fetchedResultsController.fetchedObjects?.first else {
            return NSCompoundPredicate(andPredicateWithSubpredicates: [titlePredicate])
        }

        if trackerCD.type == 1 {
            let existingRecordPredicate = NSPredicate(format: "SUBQUERY(records, $record, $record.date == %@).@count > 0", date as NSDate)
            timeTablePredicate = existingRecordPredicate
        } else {
            timeTablePredicate = NSPredicate(format: "(%K CONTAINS[n] %@) OR (%K == %@ AND (SUBQUERY(%K, $record, $record != nil AND $record.date == %@).@count > 0 OR SUBQUERY(%K, $record, $record != nil).@count == 0))", #keyPath(TrackerCD.timeTable), weekdayString, #keyPath(TrackerCD.timeTable), "", #keyPath(TrackerCD.records), date as NSDate, #keyPath(TrackerCD.records))
        }
        return NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, timeTablePredicate])
    }

    func updateDate(_ newDate: Date, _ searchText: String) {
        date = newDate
        fetchedResultsController.fetchRequest.predicate = fetchPredicate(searchText: searchText)
        try? fetchedResultsController.performFetch()
    }

    func changeCompletion(for indexPath: IndexPath, to isCompleted: Bool) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        let existingRecord = trackerCoreData.records?.first { record in
            guard let trackerRecord = record as? TrackerRecordCD, let trackerDate = trackerRecord.date else { return false }
            return Calendar.current.isDate(trackerDate, inSameDayAs: date)
        }

        if isCompleted, existingRecord == nil {
            let trackerRecordCoreData = TrackerRecordCD(context: context)
            trackerRecordCoreData.date = date
            trackerRecordCoreData.trackerRecords = trackerCoreData
            trackerRecordCoreData.id = trackerCoreData.id
            CoreDataManager.shared.saveContext()
        } else if !isCompleted, let trackerRecordCoreData = existingRecord as? TrackerRecordCD {
            context.delete(trackerRecordCoreData)
            CoreDataManager.shared.saveContext()
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    var isEmpty: Bool {
        fetchedResultsController.fetchedObjects?.isEmpty ?? true
    }

    func sectionName(for section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
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

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: insertedSections.append(sectionIndex)
        case .delete: deletedSections.append(sectionIndex)
        default: break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete: if let indexPath = indexPath { deletedIndexes.append(indexPath) }
        case .insert: if let newIndexPath = newIndexPath { insertedIndexes.append(newIndexPath) }
        case .update: if let indexPath = indexPath { updatedIndexes.append(indexPath) }
        case .move: if let oldIndexPath = indexPath, let newIndexPath = newIndexPath { movedIndexes.append((from: oldIndexPath, to: newIndexPath)) }
        @unknown default: break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerStoreUpdate(insertedSections: insertedSections, deletedSections: deletedSections, insertedIndexes: insertedIndexes, deletedIndexes: deletedIndexes, updatedIndexes: updatedIndexes, movedIndexes: movedIndexes)
        delegate?.didUpdate(update)
    }
}
