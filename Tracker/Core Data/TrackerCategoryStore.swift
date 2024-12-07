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
        fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "priority", ascending: false),
                NSSortDescriptor(key: "title", ascending: true)
            ]
        
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
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "isSelected == %@", NSNumber(value: true)),
            NSPredicate(format: "title == %@", "Закрепленные")
        ])

        do {
            let result = try context.fetch(request)
            if let firstCategory = result.first {
                return firstCategory
            } else {
                return createPinnedCategory()
            }
        } catch {
            print("Ошибка при выполнении запроса: \(error.localizedDescription)")
            return createPinnedCategory()
        }
    }
//MARK: - private methods
    private func createPinnedCategory() -> TrackerCategoryCD {
        let category = TrackerCategoryCD(context: context)
        category.title = "Закрепленные"
        category.isSelected = true
        category.priority = "1_" + "Закрепленные"

        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении новой закрепленной категории: \(error.localizedDescription)")
        }

        return category
    }


    private func addCategoryToCoreData(with title: String) throws {
        let newCategory = TrackerCategoryCD(context: context)
        newCategory.title = title
        newCategory.priority = "2_" + title
        newCategory.isSelected = false
        try context.save()
    }
    
    func categoryName(from priority: String) -> String {
        guard priority.count > 2 else { return priority }

        let trimmedName = String(priority.dropFirst(2))

        if priority.hasPrefix("1_") {
            return "Закрепленные"
        } else {
            return trimmedName
        }
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
        guard let sections = fetchedResultsController.sections, section < sections.count else {
            return 0
        }
        
        let numberOfObjects = sections[section].numberOfObjects
        
        // Проверка на наличие категории "Закрепленные"
        let hasPinnedCategory = sections[section].objects?.contains(where: {
            guard let category = $0 as? TrackerCategoryCD else { return false }
            return category.title == "Закрепленные"
        }) ?? false
        
        return hasPinnedCategory ? numberOfObjects - 1 : numberOfObjects
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
