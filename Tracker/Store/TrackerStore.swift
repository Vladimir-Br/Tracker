
import CoreData

// MARK: - TrackerStoreDelegate

protocol TrackerStoreDelegate: AnyObject {
    func storeDidChange()
}

// MARK: - TrackerStore

final class TrackerStore: NSObject, Storable {
    let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    
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
        guard let coreDataTrackers = fetchedResultsController.fetchedObjects else { return [] }
        try migrateTrackersWithNilSchedule(coreDataTrackers)
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
        try saveContext()
    }
    
    func update(_ tracker: Tracker) throws {
        let coreDataTracker = try findTracker(by: tracker.id)
        coreDataTracker.configure(from: tracker)
        try saveContext()
    }
    
    func delete(trackerId: UUID) throws {
        let tracker = try findTracker(by: trackerId)
        context.delete(tracker)
        try saveContext()
    }
    
    // MARK: - Private Methods
    
    private func migrateTrackersWithNilSchedule(_ coreDataTrackers: [TrackerCoreData]) throws {
        var needsSave = false
        for tracker in coreDataTrackers {
            if tracker.schedule == nil {
                let emptyScheduleData = try JSONEncoder().encode([Int]())
                tracker.schedule = emptyScheduleData as NSData
                needsSave = true
            }
        }
        if needsSave {
            try saveContext()
        }
    }
    
    private func mapTracker(_ coreDataTracker: TrackerCoreData) -> Tracker? {
        return Tracker(from: coreDataTracker)
    }
    
    private func findTracker(by id: UUID) throws -> TrackerCoreData {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerId), id as CVarArg)
        let results = try context.fetch(request)
        guard let tracker = results.first else { throw StoreError.trackerNotFound }
        return tracker
    }
    
    private func findCategory(by id: UUID) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryId), id as CVarArg)
        let results = try context.fetch(request)
        guard let category = results.first else { throw StoreError.categoryNotFound }
        return category
    }
}

// MARK: - TrackerCoreData Extensions

extension TrackerCoreData {
    func configure(from tracker: Tracker) {
        self.trackerId = tracker.id
        self.name = tracker.name
        self.emoji = tracker.emoji
        let colorHexString = tracker.color.hexString
        if let colorData = colorHexString.data(using: .utf8) {
            self.color = colorData as NSData
        }
        let scheduleString = tracker.schedule.map { String($0.rawValue) }.joined(separator: ",")
        if let scheduleData = scheduleString.data(using: .utf8) {
            self.schedule = scheduleData as NSData
        } else {
            self.schedule = Data() as NSData
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
    }
}
