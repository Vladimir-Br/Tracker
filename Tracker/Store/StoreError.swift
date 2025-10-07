
import Foundation

enum StoreError: Error, LocalizedError {
    case trackerNotFound
    case categoryNotFound
    case recordNotFound
    case saveError(String)
    
    // MARK: - Category Validation Errors
    
    case categoryTitleEmpty
    case categoryTitleTooLong
    case categoryHasTrackers
    case categoryCreateFailed(Error)
    case categoryUpdateFailed(Error)
    case categoryDeleteFailed(Error)
    case categoryLoadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .trackerNotFound:
            return NSLocalizedString(
                "storeError.trackerNotFound",
                comment: "Error message when tracker is not found"
            )
        case .categoryNotFound:
            return NSLocalizedString(
                "storeError.categoryNotFound",
                comment: "Error message when category is not found"
            )
        case .recordNotFound:
            return NSLocalizedString(
                "storeError.recordNotFound",
                comment: "Error message when record is not found"
            )
        case .saveError(let message):
            return String(
                format: NSLocalizedString(
                    "storeError.saveError",
                    comment: "Error message for save failure with reason"
                ),
                message
            )
            
        // MARK: - Category Errors
        
        case .categoryTitleEmpty:
            return NSLocalizedString(
                "storeError.categoryTitleEmpty",
                comment: "Error when category title is empty"
            )
        case .categoryTitleTooLong:
            return NSLocalizedString(
                "storeError.categoryTitleTooLong",
                comment: "Error when category title exceeds limit"
            )
        case .categoryHasTrackers:
            return NSLocalizedString(
                "storeError.categoryHasTrackers",
                comment: "Error when trying to delete category with trackers"
            )
        case .categoryCreateFailed(let error):
            return String(
                format: NSLocalizedString(
                    "storeError.categoryCreateFailed",
                    comment: "Error when failed to create category"
                ),
                error.localizedDescription
            )
        case .categoryUpdateFailed(let error):
            return String(
                format: NSLocalizedString(
                    "storeError.categoryUpdateFailed",
                    comment: "Error when failed to update category"
                ),
                error.localizedDescription
            )
        case .categoryDeleteFailed(let error):
            return String(
                format: NSLocalizedString(
                    "storeError.categoryDeleteFailed",
                    comment: "Error when failed to delete category"
                ),
                error.localizedDescription
            )
        case .categoryLoadFailed(let error):
            return String(
                format: NSLocalizedString(
                    "storeError.categoryLoadFailed",
                    comment: "Error when failed to load categories"
                ),
                error.localizedDescription
            )
        }
    }
}
