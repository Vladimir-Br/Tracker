
import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: StoreDelegate?
    
    // MARK: - NSFetchedResultsController
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "categoryId", ascending: true)
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
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD Operations
    
    func fetchAll() throws -> [TrackerCategory] {
        guard let coreDataCategories = fetchedResultsController.fetchedObjects else {
            return []
        }
        return coreDataCategories.compactMap { mapCategory($0) }
    }
    
    func numberOfCategories() -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func category(at indexPath: IndexPath) -> TrackerCategory? {
        let coreDataCategory = fetchedResultsController.object(at: indexPath)
        return mapCategory(coreDataCategory)
    }
    
    func add(title: String) throws -> UUID {
        let category = TrackerCategoryCoreData(context: context)
        let categoryId = UUID()
        category.categoryId = categoryId
        category.title = title
        try save()
        return categoryId
    }
    
    func update(id: UUID, title: String) throws {
        let category = try findCategory(by: id)
        category.title = title
        try save()
    }
    
    func delete(id: UUID) throws {
        let category = try findCategory(by: id)
        context.delete(category)
        try save()
    }
    
    // MARK: - Private Methods
    
    private func mapCategory(_ coreDataCategory: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let categoryId = coreDataCategory.categoryId,
              let title = coreDataCategory.title else {
            return nil
        }
        
        let trackersSet = coreDataCategory.trackers as? Set<TrackerCoreData> ?? Set()
        let trackers: [Tracker] = trackersSet.compactMap { (coreDataTracker: TrackerCoreData) -> Tracker? in
            return Tracker(from: coreDataTracker)
        }
        
        return TrackerCategory(
            id: categoryId,
            title: title,
            trackers: trackers
        )
    }
   
    private func findCategory(by id: UUID) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryId), id as CVarArg)
        let results = try context.fetch(request)
        guard let category = results.first else {
            throw StoreError.categoryNotFound
        }
        
        return category
    }
    
    private func save() throws {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error 
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidChange()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, 
                   didChange anObject: Any, 
                   at indexPath: IndexPath?, 
                   for type: NSFetchedResultsChangeType, 
                   newIndexPath: IndexPath?) {
    }
}
