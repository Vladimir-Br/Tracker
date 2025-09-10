import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD Operations
    
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
        fatalError("Функция временно недоступна")
    }
    
    // MARK: - Private Methods
    
    private func findTracker(by id: UUID) throws -> TrackerCoreData {
        fatalError("Функция временно недоступна")
    }
    
    private func findRecord(trackerId: UUID, date: Date) throws -> TrackerRecordCoreData {
        fatalError("Функция временно недоступна")
    }
    
    private func save() throws {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("❌ Ошибка сохранения записи: \(error.localizedDescription)")
            context.rollback()
            throw error 
        }
    }
}
