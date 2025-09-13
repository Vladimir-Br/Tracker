
import CoreData

final class CoreDataManager {
    
    // MARK: - Properties
    
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Initialization
    
    init(containerName: String) {
        persistentContainer = NSPersistentContainer(name: containerName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                assertionFailure("Не удалось загрузить Core Data stack: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Context
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Saving
    
    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            assertionFailure("Не удалось сохранить изменения: \(error.localizedDescription)")
        }
    }
}
