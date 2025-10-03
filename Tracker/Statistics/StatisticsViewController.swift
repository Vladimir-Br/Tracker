
import UIKit

// MARK: - StatisticsViewController

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let coreDataManager: CoreDataManager
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    // MARK: - Initialization
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        self.trackerStore = TrackerStore(context: coreDataManager.viewContext)
        self.recordStore = TrackerRecordStore(context: coreDataManager.viewContext)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
    }
}
