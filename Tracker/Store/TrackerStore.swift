
import CoreData
import UIKit

protocol StoreDelegate: AnyObject {
    func storeDidChange()
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: StoreDelegate?
    
    // MARK: - NSFetchedResultsController
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "trackerId", ascending: true)
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
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD Operations
    
    func fetchAll() throws -> [Tracker] {
        guard let coreDataTrackers = fetchedResultsController.fetchedObjects else {
            return []
        }
        return coreDataTrackers.compactMap { mapTracker($0) }
    }
    
    func numberOfTrackers() -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let coreDataTracker = fetchedResultsController.object(at: indexPath)
        return mapTracker(coreDataTracker)
    }
    
    func add(_ tracker: Tracker, categoryId: UUID) throws {
        let category = try findCategory(by: categoryId)
        let coreDataTracker = TrackerCoreData(context: context)
        coreDataTracker.configure(from: tracker)
        coreDataTracker.category = category
        
        try save()
    }
    
    func update(_ tracker: Tracker) throws {
        let coreDataTracker = try findTracker(by: tracker.id)
        coreDataTracker.configure(from: tracker)
        try save()
    }
    
    func delete(trackerId: UUID) throws {
        let tracker = try findTracker(by: trackerId)
        context.delete(tracker)
        try save()
    }
    
    // MARK: - Private Methods
    
    private func mapTracker(_ coreDataTracker: TrackerCoreData) -> Tracker? {
        return Tracker(from: coreDataTracker)
    }
    
    private func findTracker(by id: UUID) throws -> TrackerCoreData {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerId), id as CVarArg)
        let results = try context.fetch(request)
        guard let tracker = results.first else {
            throw StoreError.trackerNotFound
        }
        
        return tracker
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

// MARK: - TrackerCoreData Extensions

extension TrackerCoreData {
    func configure(from tracker: Tracker) {
        self.trackerId = tracker.id
        self.name = tracker.name
        self.emoji = tracker.emoji
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: tracker.color, requiringSecureCoding: true) {
            self.color = colorData as NSData
        }
        
        let scheduleInts = tracker.schedule.map { $0.rawValue }
        if let scheduleData = try? JSONEncoder().encode(scheduleInts) {
            self.schedule = scheduleData as NSData
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
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
