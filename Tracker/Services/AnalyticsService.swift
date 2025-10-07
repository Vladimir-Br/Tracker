
import Foundation
import AppMetricaCore

// MARK: - 📊 Analytics Event Model

enum AnalyticsEvent {
    
    // MARK: События
    
    enum Event: String {
        case open
        case close
        case click
    }
    
    // MARK: Экраны
   
    enum Screen: String {
        case main = "Main"
        case statistics = "Statistics"
        case onboarding = "Onboarding"
    }
    
    // MARK: Элементы интерфейса
    
    enum Item: String {
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
    }
}

// MARK: - 📈 Analytics Service

enum AnalyticsService {
    
    // MARK: - Activation
    
    static func activate() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "AppMetricaAPIKey") as? String,
              let configuration = AppMetricaConfiguration(apiKey: apiKey) else {
            print("⚠️ AppMetrica не активирована — проверьте API ключ")
            return
        }
        
        AppMetrica.activate(with: configuration)
        print("✅ AppMetrica активирована")
    }
    
    // MARK: - Public Methods
   
    static func trackScreenOpen(screen: AnalyticsEvent.Screen) {
        self.report(event: .open, screen: screen)
    }
    
    static func trackScreenClose(screen: AnalyticsEvent.Screen) {
        self.report(event: .close, screen: screen)
    }
    
    static func trackButtonClick(screen: AnalyticsEvent.Screen, item: AnalyticsEvent.Item) {
        self.report(event: .click, screen: screen, item: item)
    }
    
    // MARK: - Private Reporting
    
    private static func report(
        event: AnalyticsEvent.Event,
        screen: AnalyticsEvent.Screen,
        item: AnalyticsEvent.Item? = nil
    ) {
        var params: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        
        if let item = item {
            params["item"] = item.rawValue
        }
        
        print("📊 Analytics Event:", params)
        AppMetrica.reportEvent(name: "ui_event", parameters: params)
    }
}
