
import UIKit

// MARK: - StatisticsViewController

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let coreDataManager: CoreDataManager
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    private var statisticsData: [StatisticsItem] = []
    
    // MARK: - UI Elements
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Nothing To Analyze")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.empty", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Colors.labelPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        self.setupNavigationBar()
        self.setupView()
        self.setupTableView()
        self.setupConstraints()
        self.setupStoreDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadStatistics()
    }
}

// MARK: - Private Methods

private extension StatisticsViewController {
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = NSLocalizedString("statistics.title", comment: "")
    }
    
    func setupView() {
        self.view.backgroundColor = Colors.background
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.emptyStateImageView)
        self.view.addSubview(self.emptyStateLabel)
    }
    
    func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(
            StatisticsCell.self,
            forCellReuseIdentifier: StatisticsCell.reuseIdentifier
        )
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 77),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 8),
            self.emptyStateLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 16),
            self.emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -16)
        ])
    }
    
    func setupStoreDelegate() {
        self.trackerStore.delegate = self
        self.recordStore.delegate = self
    }
    
    func loadStatistics() {
        guard let allRecords = try? self.recordStore.fetchAll() else {
            self.statisticsData = []
            self.updateUIState()
            return
        }
        
        guard !allRecords.isEmpty else {
            self.statisticsData = []
            self.updateUIState()
            return
        }
        
        let completedCount = self.calculateCompletedTrackers(from: allRecords)
        let bestPeriod = self.calculateBestPeriod(from: allRecords)
        let perfectDays = self.calculatePerfectDays(from: allRecords)
        let average = self.calculateAverage(from: allRecords)
        
        self.statisticsData = [
            StatisticsItem(title: NSLocalizedString("statistics.bestPeriod", comment: ""), value: bestPeriod),
            StatisticsItem(title: NSLocalizedString("statistics.perfectDays", comment: ""), value: perfectDays),
            StatisticsItem(title: NSLocalizedString("statistics.completed", comment: ""), value: completedCount),
            StatisticsItem(title: NSLocalizedString("statistics.average", comment: ""), value: average)
        ]
        
        self.updateUIState()
    }
    
    func updateUIState() {
        let isEmpty = self.statisticsData.isEmpty
        
        self.tableView.isHidden = isEmpty
        self.emptyStateImageView.isHidden = !isEmpty
        self.emptyStateLabel.isHidden = !isEmpty
        
        self.tableView.reloadData()
    }
    
    func calculateCompletedTrackers(from records: [TrackerRecord]) -> Int {
        return records.count
    }
    
    func calculateBestPeriod(from records: [TrackerRecord]) -> Int {
        let sortedDates = records
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            
            if currentDate == previousDate {
                continue
            }
            
            if let daysBetween = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day,
               daysBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    func calculatePerfectDays(from records: [TrackerRecord]) -> Int {
        guard let allTrackers = try? self.trackerStore.fetchAll() else {
            return 0
        }
        
        let recordsByDate = Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
        
        var perfectDaysCount = 0
        
        for (date, dayRecords) in recordsByDate {
            let scheduledTrackers = allTrackers.filter { tracker in
                self.isTrackerScheduled(tracker, on: date)
            }
            
            let completedTrackerIDs = Set(dayRecords.map { $0.trackerId })
            let scheduledTrackerIDs = Set(scheduledTrackers.map { $0.id })
            
            if !scheduledTrackerIDs.isEmpty && completedTrackerIDs == scheduledTrackerIDs {
                perfectDaysCount += 1
            }
        }
        
        return perfectDaysCount
    }
    
    func calculateAverage(from records: [TrackerRecord]) -> Int {
        let uniqueDays = Set(records.map { Calendar.current.startOfDay(for: $0.date) })
        
        guard !uniqueDays.isEmpty else { return 0 }
        
        let average = Double(records.count) / Double(uniqueDays.count)
        return Int(average.rounded())
    }
    
    func isTrackerScheduled(_ tracker: Tracker, on date: Date) -> Bool {
        guard !tracker.schedule.isEmpty else {
            return true
        }
        
        guard let weekday = Calendar.current.weekday(for: date) else {
            return false
        }
        
        return tracker.schedule.contains(weekday)
    }
}

// MARK: - UITableViewDataSource

extension StatisticsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.statisticsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticsCell else {
            return UITableViewCell()
        }
        
        let item = self.statisticsData[indexPath.section]
        cell.configure(with: item)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension StatisticsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
}

// MARK: - TrackerStoreDelegate

extension StatisticsViewController: TrackerStoreDelegate {
    
    func storeDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.loadStatistics()
        }
    }
}

// MARK: - TrackerRecordStoreDelegate

extension StatisticsViewController: TrackerRecordStoreDelegate {
    
    func trackerRecordStoreDidUpdateRecords(_ store: TrackerRecordStore) {
        DispatchQueue.main.async { [weak self] in
            self?.loadStatistics()
        }
    }
}
