
import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Properties
    private let coreDataManager: CoreDataManager
    
    // MARK: - Initialization
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBarAppearance()
    }

    private func setupTabs() {
        let trackersVC = TrackersViewController(coreDataManager: coreDataManager)
        let statisticsVC = StatisticsViewController(coreDataManager: coreDataManager)

        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Record"),
            selectedImage: UIImage(named: "Record")
        )
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Hare"),
            selectedImage: UIImage(named: "Hare")
        )

        viewControllers = [
            UINavigationController(rootViewController: trackersVC),
            UINavigationController(rootViewController: statisticsVC)
        ]
    }
    
    private func setupTabBarAppearance() {
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = UIColor.systemGray4
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColor(named: "Blue [day]")
        tabBar.unselectedItemTintColor = .systemGray
    }
}



