
import Foundation
import AppMetricaCore

// MARK: - Analytics Constants

struct Analytics {
    // Events
    static let eventOpen = "open"
    static let eventClose = "close"
    static let eventClick = "click"
    
    // Screens
    static let screenMain = "Main"
    
    // Items
    static let itemAddTrack = "add_track"
    static let itemTrack = "track"
    static let itemFilter = "filter"
    static let itemEdit = "edit"
    static let itemDelete = "delete"
}

// MARK: - Analytics Service

struct AnalyticsService {
    
    // MARK: - Activation
    
    static func activate() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "AppMetricaAPIKey") as? String,
              let configuration = AppMetricaConfiguration(apiKey: apiKey) else {
            print("⚠️ AppMetrica не активирована - проверьте API ключ")
            return
        }
        
        AppMetrica.activate(with: configuration)
        print("✅ AppMetrica активирована")
    }
    
    // MARK: - Event Tracking
    
    static func trackScreenOpen(screen: String) {
        let params: [AnyHashable: Any] = [
            "event": Analytics.eventOpen,
            "screen": screen
        ]
        
        print("📊 Analytics: \(params)")
        AppMetrica.reportEvent(name: "ui_event", parameters: params)
    }
    
    static func trackScreenClose(screen: String) {
        let params: [AnyHashable: Any] = [
            "event": Analytics.eventClose,
            "screen": screen
        ]
        
        print("📊 Analytics: \(params)")
        AppMetrica.reportEvent(name: "ui_event", parameters: params)
    }
    
    static func trackButtonClick(screen: String, item: String) {
        let params: [AnyHashable: Any] = [
            "event": Analytics.eventClick,
            "screen": screen,
            "item": item
        ]
        
        print("📊 Analytics: \(params)")
        AppMetrica.reportEvent(name: "ui_event", parameters: params)
    }
}
