
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
            return "Трекер не найден"
        case .categoryNotFound:
            return "Категория не найдена"
        case .recordNotFound:
            return "Запись не найдена"
        case .saveError(let message):
            return "Ошибка сохранения: \(message)"
            
        // MARK: - Category Errors
        
        case .categoryTitleEmpty:
            return "Название категории не может быть пустым"
        case .categoryTitleTooLong:
            return "Название категории не должно превышать 38 символов"
        case .categoryHasTrackers:
            return "Нельзя удалить категорию, в которой есть трекеры"
        case .categoryCreateFailed(let error):
            return "Не удалось создать категорию: \(error.localizedDescription)"
        case .categoryUpdateFailed(let error):
            return "Не удалось обновить категорию: \(error.localizedDescription)"
        case .categoryDeleteFailed(let error):
            return "Не удалось удалить категорию: \(error.localizedDescription)"
        case .categoryLoadFailed(let error):
            return "Не удалось загрузить категории: \(error.localizedDescription)"
        }
    }
}
