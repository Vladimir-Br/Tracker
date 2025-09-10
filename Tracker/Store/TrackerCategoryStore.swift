
import CoreData
import UIKit

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD Operations
    
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
   
    private func findCategory(by id: UUID) throws -> TrackerCategoryCoreData {
        fatalError("Функция временно недоступна")
    }
    
    private func save() throws {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("❌ Ошибка сохранения категории: \(error.localizedDescription)")
            context.rollback()
            throw error 
        }
    }
}
