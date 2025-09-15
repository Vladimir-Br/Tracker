
import UIKit

// MARK: - SceneDelegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    
    // MARK: - UIWindowSceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let coreDataManager = appDelegate.coreDataManager else {
            assertionFailure("CoreDataManager не инициализирован")
            return
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TabBarController(coreDataManager: coreDataManager)
        window?.makeKeyAndVisible()
    }

}
