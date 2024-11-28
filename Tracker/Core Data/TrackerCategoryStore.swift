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
        fetchRequest.predicate = NSPredicate(format: "trackers.@count > 0")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
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
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
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
