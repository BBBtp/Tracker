import Foundation
import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
   
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    private var updatedIndexes: [IndexPath] = []
    private var movedIndexes: [(from: IndexPath, to: IndexPath)] = []
    
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func addRecord(for id: UUID, date: Date) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let trackerEntity = try context.fetch(fetchRequest).first {
                let newRecord = TrackerRecordCD(context: context)
                newRecord.date = date
                newRecord.id = id
                newRecord.trackerRecords = trackerEntity
                trackerEntity.addToRecords(newRecord)
                try context.save()
                return true
            } else {
                print("Tracker not found for ID: \(id)")
                return false
            }
        } catch {
            print("Error adding record: \(error)")
            return false
        }
    }
    
    func removeRecord(for trackerId: UUID, date: Date) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerRecords.id == %@", trackerId as CVarArg)
        
        do {
            if let recordToDelete = try context.fetch(fetchRequest).first {
                context.delete(recordToDelete)
                try context.save()
                return true
            } else {
                print("Record not found for trackerId: \(trackerId) and date: \(date)")
                return false
            }
        } catch {
            print("Error deleting record: \(error)")
            return false
        }
    }
}
