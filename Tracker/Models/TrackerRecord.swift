
import Foundation

// MARK: - TrackerRecord

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
        hasher.combine(date)
    }
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.trackerId == rhs.trackerId && lhs.date == rhs.date
    }
}
