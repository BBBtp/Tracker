import Foundation
import CoreData
import UIKit

struct TrackerCategoryStoreUpdate {
    let insertedIndices: [IndexPath]
    let deletedIndices: [IndexPath]
    let updatedIndices: [IndexPath]
    let movedIndices: [(from: IndexPath, to: IndexPath)]
}
protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}
final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorTransformer()
    private let uiWeekDayMarshalling = WeekDayArrayTransformer()
    weak var delegate: TrackerCategoryStoreDelegate?
    private var insertedIndices: [IndexPath] = []
    private var deletedIndices: [IndexPath] = []
    private var updatedIndices: [IndexPath] = []
    private var movedIndices: [(from: IndexPath, to: IndexPath)] = []
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
//MARK: - public methods
    func addCategory(title: String) {
        do{
            try addCategoryToCoreData(with: title)
            print(title)
        }
        catch{
            print("\(error.localizedDescription)")
        }
    }
    
    func fetchOrCreatePinnedCategory() -> TrackerCategoryCD {
        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        request.predicate = NSPredicate(format: "isSelected == %@", NSNumber(value: true))

        do {
            let result = try context.fetch(request)
            if let firstCategory = result.first {
                return firstCategory
            } else {
                return addCategorySelected("Закрепленные", isPinned: true)
            }
        } catch {
            print("Ошибка при выполнении запроса: \(error.localizedDescription)")
            return addCategorySelected("Закрепленные", isPinned: true)
        }
    }

//MARK: - private methods
    private func addCategorySelected(_ name: String, isPinned: Bool) -> TrackerCategoryCD {
        let category = TrackerCategoryCD(context: context)
        category.title = name
        category.isSelected = isPinned

        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении контекста: \(error.localizedDescription)")
        }

        return category
    }

    private func addCategoryToCoreData(with title: String) throws {
        let newCategory = TrackerCategoryCD(context: context)
        newCategory.title = title
        try context.save()
    }
    
    
    func categoryName(at indexPath: IndexPath) -> String? {
        let categoryData = fetchedResultsController.object(at: indexPath)
        return categoryData.title
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    var isEmpty: Bool {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            return fetchedObjects.isEmpty
        } else {
            return true
        }
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndices.removeAll()
        deletedIndices.removeAll()
        updatedIndices.removeAll()
        movedIndices.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath {
                deletedIndices.append(indexPath)
            }
        case .insert:
            if let newIndexPath {
                insertedIndices.append(newIndexPath)
            }
        case .update:
            if let indexPath {
                updatedIndices.append(indexPath)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndices.append((from: oldIndexPath, to: newIndexPath))
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerCategoryStoreUpdate(
            insertedIndices: insertedIndices,
            deletedIndices: deletedIndices,
            updatedIndices: updatedIndices,
            movedIndices: movedIndices
        )
        delegate?.didUpdate(update)
    }
}
