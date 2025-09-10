
import CoreData
import UIKit

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD Operations
    
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
    
    private func findTracker(by id: UUID) throws -> TrackerCoreData {
        fatalError("Функция временно недоступна")
    }
    
    private func findCategory(by id: UUID) throws -> TrackerCategoryCoreData {
        fatalError("Функция временно недоступна")
    }
    
    private func save() throws {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("❌ Ошибка сохранения трекера: \(error.localizedDescription)")
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
        self.color = tracker.color
        
        let scheduleInts = tracker.schedule.map { $0.rawValue }
        if let scheduleData = try? JSONEncoder().encode(scheduleInts) {
            self.schedule = scheduleData as NSData
        }
    }
}
