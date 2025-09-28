
import UIKit

// MARK: - Tracker

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let isPinned: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        color: UIColor,
        emoji: String,
        schedule: [Weekday],
        isPinned: Bool = false
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isPinned = isPinned
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
        
        self.init(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: coreDataObject.isPinned
        )
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
        case .sunday:
            return NSLocalizedString("weekday.sunday.full", comment: "Full name for Sunday")
        case .monday:
            return NSLocalizedString("weekday.monday.full", comment: "Full name for Monday")
        case .tuesday:
            return NSLocalizedString("weekday.tuesday.full", comment: "Full name for Tuesday")
        case .wednesday:
            return NSLocalizedString("weekday.wednesday.full", comment: "Full name for Wednesday")
        case .thursday:
            return NSLocalizedString("weekday.thursday.full", comment: "Full name for Thursday")
        case .friday:
            return NSLocalizedString("weekday.friday.full", comment: "Full name for Friday")
        case .saturday:
            return NSLocalizedString("weekday.saturday.full", comment: "Full name for Saturday")
        }
    }
    
    var shortTitle: String {
        switch self {
        case .sunday:
            return NSLocalizedString("weekday.sunday.short", comment: "Short name for Sunday")
        case .monday:
            return NSLocalizedString("weekday.monday.short", comment: "Short name for Monday")
        case .tuesday:
            return NSLocalizedString("weekday.tuesday.short", comment: "Short name for Tuesday")
        case .wednesday:
            return NSLocalizedString("weekday.wednesday.short", comment: "Short name for Wednesday")
        case .thursday:
            return NSLocalizedString("weekday.thursday.short", comment: "Short name for Thursday")
        case .friday:
            return NSLocalizedString("weekday.friday.short", comment: "Short name for Friday")
        case .saturday:
            return NSLocalizedString("weekday.saturday.short", comment: "Short name for Saturday")
        }
    }
}
