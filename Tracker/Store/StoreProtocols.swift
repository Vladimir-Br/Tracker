
import CoreData

protocol Storable: AnyObject {
    var context: NSManagedObjectContext { get }
    func saveContext() throws
}

extension Storable {
    func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

