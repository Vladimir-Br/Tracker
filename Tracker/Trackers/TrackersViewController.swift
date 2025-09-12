import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Static Properties
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    // MARK: - Properties
    private let coreDataManager: CoreDataManager
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    
    // MARK: - Initialization
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        self.trackerStore = TrackerStore(context: coreDataManager.viewContext)
        self.categoryStore = TrackerCategoryStore(context: coreDataManager.viewContext)
        self.recordStore = TrackerRecordStore(context: coreDataManager.viewContext)
        super.init(nibName: nil, bundle: nil)
        
       setupDelegates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var visibleCategories: [TrackerCategory] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        
        return categories.compactMap { category -> TrackerCategory? in
            let trackers = category.trackers.filter { tracker in
                if tracker.schedule.isEmpty {
                    return true
                }
                return tracker.schedule.contains { $0.rawValue == weekday }
            }
            
            guard !trackers.isEmpty else {
                return nil
            }
            
            return TrackerCategory(id: category.id, title: category.title, trackers: trackers)
        }
    }
    
    // MARK: - UI Elements
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1) // #F0F0F0
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(named: "Plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        button.tintColor = UIColor(named: "Black [day]")
        return button
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Поиск"
        controller.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        controller.searchBar.searchTextField.textColor = UIColor(named: "Gray [day]")
        return controller
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StarCircle")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "Black [day]")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupLayout()
        registerViews()
        loadData()
        updateUI()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Трекеры"
        navigationItem.leftBarButtonItem = addButton
        let dateContainerView = UIView()
        dateContainerView.translatesAutoresizingMaskIntoConstraints = false
        dateContainerView.addSubview(datePicker)
        dateContainerView.addSubview(dateLabel)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateContainerView)
    
        navigationItem.searchController = searchController
        
        NSLayoutConstraint.activate([
            dateContainerView.widthAnchor.constraint(equalToConstant: 77),
            dateContainerView.heightAnchor.constraint(equalToConstant: 34),
            
            datePicker.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: dateContainerView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: dateContainerView.bottomAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: dateContainerView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: dateContainerView.bottomAnchor)
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func registerViews() {
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        let newHabitVC = NewHabitViewController(coreDataManager: coreDataManager)
        newHabitVC.delegate = self
        let navigationController = UINavigationController(rootViewController: newHabitVC)
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func loadData() {
        loadCategories()
        loadCompletedTrackers()
    }
    
    private func loadCategories() {
        do {
            categories = try categoryStore.fetchAll()
        } catch {
            categories = []
        }
    }
    
    private func loadCompletedTrackers() {
        do {
            let records = try recordStore.fetchAll()
            completedTrackers = Set(records)
        } catch {
            completedTrackers = []
        }
    }
    
    private func updateDateLabel(with date: Date) {
        dateLabel.text = Self.dateFormatter.string(from: date)
    }
    
    private func updateUI() {
        updateDateLabel(with: currentDate)
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
    
    private func updatePlaceholderVisibility() {
        let isVisible = !visibleCategories.isEmpty
        placeholderImageView.isHidden = isVisible
        placeholderLabel.isHidden = isVisible
        collectionView.isHidden = !isVisible
    }
    
    private func isTrackerCompletedToday(_ trackerId: UUID) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        
        return completedTrackers.contains { record in
            record.trackerId == trackerId && 
            calendar.isDate(record.date, inSameDayAs: today)
        }
    }
    
    private func addTracker(_ tracker: Tracker, toCategory title: String) {
        do {
            var existingCategory: TrackerCategory?
            
            let allCategories = try categoryStore.fetchAll()
            existingCategory = allCategories.first { $0.title == title }
            
            let categoryId: UUID
            if let category = existingCategory {
                categoryId = category.id
            } else {
                categoryId = try categoryStore.add(title: title)
            }
            
            try trackerStore.add(tracker, categoryId: categoryId)
            
        } catch {
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = isTrackerCompletedToday(tracker.id)
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.delegate = self
        cell.configure(with: tracker, isCompleted: isCompleted, count: completedDays, at: currentDate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        
        header.setTitle(visibleCategories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 16 * 2 - 9
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func didTapCompleteButton(for cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let record = TrackerRecord(trackerId: tracker.id, date: currentDate)
        
        do {
            if completedTrackers.contains(record) {
                try recordStore.delete(trackerId: tracker.id, date: currentDate)
                completedTrackers.remove(record)
            } else {
                try recordStore.add(record)
                completedTrackers.insert(record)
            }
            
        } catch {
        }
    }
}

// MARK: - NewHabitViewControllerDelegate

extension TrackersViewController: NewHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        addTracker(tracker, toCategory: "Важное")
    }
}

// MARK: - Store Delegates

extension TrackersViewController: StoreDelegate {
    
    func storeDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
            self?.updateUI()
        }
    }

    private func setupDelegates() {
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
    }
}
