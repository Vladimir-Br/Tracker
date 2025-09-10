
import CoreData

final class CoreDataManager {
    
    // MARK: - Properties
    
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Initialization
    
    init(containerName: String) {
        DaysValueTransformer.register()
        self.persistentContainer = NSPersistentContainer(name: containerName)
        self.persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("❌ Ошибка Core Data: \(error.localizedDescription)")
                assertionFailure("Не удалось загрузить Core Data stack")
            } else {
                print("✅ Core Data stack успешно загружен")
            }
        }
    }
    
    // MARK: - Context
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Saving
   
    func saveContext() {
        let context = persistentContainer.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("❌ Ошибка сохранения: \(error.localizedDescription)")
            assertionFailure("Не удалось сохранить изменения")
        }
    }
}
