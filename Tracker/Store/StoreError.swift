
import Foundation

enum StoreError: Error, LocalizedError {
    case trackerNotFound
    case categoryNotFound
    case recordNotFound
    case saveError(String)
    
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
        }
    }
}
