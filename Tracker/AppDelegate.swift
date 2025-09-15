
import UIKit
import CoreData

// MARK: - AppDelegate

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var coreDataManager: CoreDataManager?

    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        coreDataManager = CoreDataManager(containerName: "Tracker")
        
        return true
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    
    func applicationWillTerminate(_ application: UIApplication) {
        coreDataManager?.saveContext()
    }

}
