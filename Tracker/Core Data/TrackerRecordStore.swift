import Foundation
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecord(for id: UUID, date: Date, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let trackerEntity = try context.fetch(fetchRequest).first {
                let newRecord = TrackerRecordCD(context: context)
                newRecord.date = date
                newRecord.id = id
                newRecord.trackerRecords = trackerEntity
                trackerEntity.addToRecords(newRecord)
                CoreDataManager.shared.saveContext()
                completion(true)
            } else {
                print("Tracker not found for ID: \(id)")
                completion(false)
            }
        } catch {
            print("Error adding record: \(error)")
            completion(false)
        }
    }
    
    func removeRecord(for trackerId: UUID, date: Date, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerRecords.id == %@", trackerId as CVarArg)
        
        do {
            if let recordToDelete = try context.fetch(fetchRequest).first {
                context.delete(recordToDelete)
                CoreDataManager.shared.saveContext()
                completion(true)
            } else {
                print("Record not found for trackerId: \(trackerId) and date: \(date)")
                completion(false)
            }
        } catch {
            print("Error deleting record: \(error)")
            completion(false)
        }
    }
    
    func fetchRecords(completion: @escaping ([TrackerRecordModel]) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        
        do {
            let recordsFromCoreData = try context.fetch(fetchRequest)
            let records: [TrackerRecordModel] = recordsFromCoreData.compactMap { record in
                guard
                    let date = record.date,
                    let trackerEntity = record.trackerRecords,
                    let trackerID = trackerEntity.id,
                    let trackerTitle = trackerEntity.title,
                    let colorString = trackerEntity.color,
                    let timetableString = trackerEntity.timeTable
                else {
                   
                    return nil
                }
                
                let color = UIColorTransformer().stringToColor(from: colorString)
                let weekDays = WeekDayArrayTransformer().StringToWeekDayArray(timetableString)
                
                let trackerModel = TrackerModel(
                    id: trackerID,
                    title: trackerTitle,
                    color: color,
                    emoji: trackerEntity.emoji ?? "",
                    timeTable: weekDays,
                    type: trackerEntity.type == 1 ? .habit : .irregularEvent
                )
                
                return TrackerRecordModel(id: trackerModel.id, date: date)
            }
            completion(records)
        } catch {
            print("Ошибка при получении записей: \(error)")
            completion([])
        }
    }
}
