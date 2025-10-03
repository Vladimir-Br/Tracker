
import UIKit

// MARK: - App Colors

final class Colors {
    
    // MARK: - Background
   
    static let background = UIColor.systemBackground
    static let cellBackground = UIColor(named: "Cell Background") ?? .secondarySystemGroupedBackground
    
    // MARK: - Text
    
    static let labelPrimary = UIColor.label
    static let labelSecondary = UIColor(named: "Black [day]") ?? .label
    
    // MARK: - Accent
    
    static let blue = UIColor(named: "Blue [day]") ?? .systemBlue
    static let gray = UIColor(named: "Gray [day]") ?? .systemGray
    
    // MARK: - Buttons
    
    static let buttonPrimary = UIColor(named: "Button Primary") ?? .label
    static let buttonPrimaryText = UIColor(named: "Button Primary Text") ?? .systemBackground
    static let buttonText = UIColor.white
}
