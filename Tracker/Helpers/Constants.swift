
import UIKit

// MARK: - MVVM Binding

typealias Binding<T> = (T) -> Void

// MARK: - TrackerFilter

enum TrackerFilter: Int, CaseIterable {
    case all = 0
    case today = 1
    case completed = 2
    case uncompleted = 3
    
    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("filters.all", comment: "All trackers filter")
        case .today:
            return NSLocalizedString("filters.today", comment: "Today's trackers filter")
        case .completed:
            return NSLocalizedString("filters.completed", comment: "Completed trackers filter")
        case .uncompleted:
            return NSLocalizedString("filters.uncompleted", comment: "Uncompleted trackers filter")
        }
    }
    
    var isResetFilter: Bool {
        switch self {
        case .all, .today:
            return true
        case .completed, .uncompleted:
            return false
        }
    }
}

// MARK: - EmojiConstants

enum EmojiConstants {
    static let emojis: [String] = [
        "😊", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
}

// MARK: - ColorConstants

enum ColorConstants {
    static let colors: [UIColor] = {
        var colors: [UIColor] = []
        for i in 1...18 {
            let colorName = "ColorSelection\(i)"
            let color = UIColor(named: colorName) ?? .systemGray
            colors.append(color)
        }
        return colors
    }()
}

// MARK: - LayoutConstants

enum LayoutConstants {
    
    static let cellSize: CGFloat = 52
    static let emojiSize: CGSize = CGSize(width: 32, height: 38)
    
    static let emojiHorizontalSpacing: CGFloat = 5
    static let emojiVerticalSpacing: CGFloat = 5
    static let emojiLeftInset: CGFloat = 18
    static let emojiRightInset: CGFloat = 18
    
    static let cellSpacing: CGFloat = 5
    static let sectionInset: CGFloat = 18
    
    static let cellCornerRadius: CGFloat = 16
}
