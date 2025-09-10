
import Foundation

@objc(DaysValueTransformer)
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Tracker.Weekday] else { return nil }
        let rawValues = days.map { $0.rawValue }
        return try? JSONEncoder().encode(rawValues) as NSData
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        guard let rawValues = try? JSONDecoder().decode([Int].self, from: data) else { return nil }
        return rawValues.compactMap { Tracker.Weekday(rawValue: $0) }
    }
    
    static func register() {
        let name = NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        ValueTransformer.setValueTransformer(DaysValueTransformer(), forName: name)
    }
}
