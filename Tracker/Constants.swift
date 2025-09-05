
import Foundation
import UIKit

enum Constants {
    static let defaultCategoryTitle = "Важное"
}

enum EmojiConstants {
    static let emojis: [String] = [
        "😊", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
}

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
