
import UIKit

// MARK: - Tracker

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    
    init(id: UUID = UUID(), name: String, color: UIColor, emoji: String, schedule: [Weekday]) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
    
    init?(from coreDataObject: TrackerCoreData) {
        guard let id = coreDataObject.trackerId,
              let name = coreDataObject.name,
              let emoji = coreDataObject.emoji,
              let colorData = coreDataObject.color as? Data,
              let colorHexString = String(data: colorData, encoding: .utf8),
              let color = UIColor(hexString: colorHexString) else {
            return nil
        }
        
        let schedule: [Weekday]
        if let scheduleData = coreDataObject.schedule as? Data,
           let scheduleString = String(data: scheduleData, encoding: .utf8) {
            let scheduleInts = scheduleString.split(separator: ",").compactMap { Int($0) }
            schedule = scheduleInts.compactMap { Weekday(rawValue: $0) }
        } else {
            
            schedule = []
        }
        
        self.init(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}

// MARK: - Weekday

enum Weekday: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var title: String {
        switch self {
        case .sunday: return "Воскресенье"
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .sunday: return "Вс"
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        }
    }
}
