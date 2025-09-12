
import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: StoreDelegate?
    
    // MARK: - NSFetchedResultsController
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
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
    
    func fetchAll() throws -> [TrackerRecord] {
        guard let coreDataRecords = fetchedResultsController.fetchedObjects else {
            return []
        }
        return coreDataRecords.compactMap { mapRecord($0) }
    }
    
    func numberOfRecords() -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func record(at indexPath: IndexPath) -> TrackerRecord? {
        let coreDataRecord = fetchedResultsController.object(at: indexPath)
        return mapRecord(coreDataRecord)
    }
    
    func add(_ record: TrackerRecord) throws {
        let tracker = try findTracker(by: record.trackerId)
        let coreDataRecord = TrackerRecordCoreData(context: context)
        coreDataRecord.date = record.date
        coreDataRecord.tracker = tracker
        try save()
    }
    
    func delete(trackerId: UUID, date: Date) throws {
        let record = try findRecord(trackerId: trackerId, date: date)
        context.delete(record)
        try save()
    }
    
    func exists(trackerId: UUID, date: Date) -> Bool {
        do {
            _ = try findRecord(trackerId: trackerId, date: date)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func mapRecord(_ coreDataRecord: TrackerRecordCoreData) -> TrackerRecord? {
        guard let date = coreDataRecord.date,
              let tracker = coreDataRecord.tracker,
              let trackerId = tracker.trackerId else {
            return nil
        }
        
        return TrackerRecord(
            trackerId: trackerId,
            date: date
        )
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
    
    private func findRecord(trackerId: UUID, date: Date) throws -> TrackerRecordCoreData {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K.%K == %@ AND %K == %@",
                                       #keyPath(TrackerRecordCoreData.tracker), 
                                       #keyPath(TrackerCoreData.trackerId), 
                                       trackerId as CVarArg,
                                       #keyPath(TrackerRecordCoreData.date), 
                                       date as CVarArg)
       
        let results = try context.fetch(request)
        guard let record = results.first else {
            throw StoreError.recordNotFound
        }
        
        return record
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

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
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
