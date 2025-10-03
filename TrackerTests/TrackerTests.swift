
import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    // MARK: - Properties
    
    private var coreDataManager: CoreDataManager!
    
    // MARK: - Class Setup & Teardown
    
    override class func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
    }
    
    override class func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }
    
    // MARK: - Instance Setup & Teardown
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager(containerName: "Tracker", inMemory: true)
    }
    
    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func makeNavigationController() -> UINavigationController {
        let viewController = TrackersViewController(coreDataManager: coreDataManager)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.loadViewIfNeeded()
        return navigationController
    }
    
    // MARK: - Tests
    
    // MARK: Light Mode Tests
    
    func testTrackersViewControllerEmpty_Light() {
        let vc = makeNavigationController()
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testTrackersViewControllerWithTrackers_Light() {
        let categoryStore = TrackerCategoryStore(context: coreDataManager.viewContext)
        let trackerStore = TrackerStore(context: coreDataManager.viewContext)
        let categoryId = try! categoryStore.add(title: "Важное")
        
        let tracker = Tracker(
            name: "Поливать растения",
            color: UIColor(named: "ColorSelection1") ?? .systemRed,
            emoji: "❤️",
            schedule: Weekday.allCases
        )
        
        try! trackerStore.add(tracker, categoryId: categoryId)
        
        let vc = makeNavigationController()
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    // MARK: Dark Mode Tests
    
    func testTrackersViewControllerEmpty_Dark() {
        let vc = makeNavigationController()
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark))
        )
    }
    
    func testTrackersViewControllerWithTrackers_Dark() {
        let categoryStore = TrackerCategoryStore(context: coreDataManager.viewContext)
        let trackerStore = TrackerStore(context: coreDataManager.viewContext)
        let categoryId = try! categoryStore.add(title: "Важное")
        
        let tracker = Tracker(
            name: "Поливать растения",
            color: UIColor(named: "ColorSelection1") ?? .systemRed,
            emoji: "❤️",
            schedule: Weekday.allCases
        )
        
        try! trackerStore.add(tracker, categoryId: categoryId)
        
        let vc = makeNavigationController()
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark))
        )
    }
}
