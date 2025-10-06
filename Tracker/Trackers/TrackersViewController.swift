
import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private let coreDataManager: CoreDataManager
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private var currentFilter: TrackerFilter = .all
    private var searchText: String = ""
    
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
    
    // MARK: - Computed Properties
    
    private var visibleCategories: [TrackerCategory] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        
        var pinned: [Tracker] = []
        var regularCategories: [TrackerCategory] = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
               let matchesSchedule = tracker.schedule.isEmpty || tracker.schedule.contains(where: { $0.rawValue == weekday })
                guard matchesSchedule else { return false }
                
                if !searchText.isEmpty {
                    let matchesSearch = tracker.name.lowercased().contains(searchText.lowercased())
                    guard matchesSearch else { return false }
                }
                
                switch currentFilter {
                case .all:
                    return true
                case .today:
                    return true 
                case .completed:
                    return isTrackerCompleted(tracker.id)
                case .uncompleted:
                    return !isTrackerCompleted(tracker.id)
                }
            }
            
            let pinnedInCategory = filteredTrackers.filter { $0.isPinned }
            pinned.append(contentsOf: pinnedInCategory)
            
            let nonPinnedTrackers = filteredTrackers.filter { !$0.isPinned }
            guard !nonPinnedTrackers.isEmpty else { continue }
            regularCategories.append(
                TrackerCategory(
                    id: category.id,
                    title: category.title,
                    trackers: nonPinnedTrackers
                )
            )
        }
        
        if pinned.isEmpty {
            return regularCategories
        }
        
        let pinnedCategory = TrackerCategory(
            id: UUID(),
            title: NSLocalizedString(
                "trackers.pinned.section.title",
                comment: "Title for pinned trackers section"
            ),
            trackers: pinned
        )
        
        return [pinnedCategory] + regularCategories
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
        picker.locale = Locale.current
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
        button.tintColor = Colors.labelPrimary
        return button
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = NSLocalizedString(
            "trackers.search.placeholder",
            comment: "Placeholder for tracker search bar"
        )
        controller.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        controller.searchBar.searchTextField.textColor = UIColor(resource: .grayDay)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        return controller
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Colors.labelPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters.button.title", comment: "Filters button title"), for: .normal)
        button.setTitleColor(Colors.buttonText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = Colors.blue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.trackScreenOpen(screen: Analytics.screenMain)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.trackScreenClose(screen: Analytics.screenMain)
    }
    
    // MARK: - Setup Methods
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString(
            "trackers.title",
            comment: "Navigation title for trackers screen"
        )
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
        view.backgroundColor = Colors.background
        
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 66, right: 0)
    }
    
    private func registerViews() {
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        AnalyticsService.trackButtonClick(screen: Analytics.screenMain, item: Analytics.itemAddTrack)
        
        let habitVC = HabitViewController(mode: .create, coreDataManager: coreDataManager)
        habitVC.delegate = self
        let navigationController = UINavigationController(rootViewController: habitVC)
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateUI()
    }
    
    @objc private func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: - Private Methods
    
    private func loadData() {
        loadCategories()
        loadCompletedTrackers()
        loadCurrentFilter()
    }
    
    private func isTrackerCompleted(_ trackerId: UUID) -> Bool {
        return completedTrackers.contains { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
    }
    
    private func loadCategories() {
        do {
            categories = try categoryStore.fetchAll()
        } catch {
            categories = []
        }
    }

    private func makeContextMenu(for tracker: Tracker, at indexPath: IndexPath) -> UIMenu {
        let pinTitle = tracker.isPinned
            ? NSLocalizedString(
                "trackers.context.unpin",
                comment: "Context menu title for unpinning tracker"
            )
            : NSLocalizedString(
                "trackers.context.pin",
                comment: "Context menu title for pinning tracker"
            )
        let pinAction = UIAction(title: pinTitle) { [weak self] _ in
            self?.togglePin(with: tracker.id)
        }
        let editAction = UIAction(
            title: NSLocalizedString(
                "trackers.context.edit",
                comment: "Context menu title for editing tracker"
            )
        ) { [weak self] _ in
            AnalyticsService.trackButtonClick(screen: Analytics.screenMain, item: Analytics.itemEdit)
            self?.editTracker(with: tracker.id)
        }
        let deleteAction = UIAction(
            title: NSLocalizedString(
                "trackers.context.delete",
                comment: "Context menu title for deleting tracker"
            ),
            attributes: .destructive
        ) { [weak self] _ in
            AnalyticsService.trackButtonClick(screen: Analytics.screenMain, item: Analytics.itemDelete)
            self?.deleteTracker(with: tracker.id)
        }
        return UIMenu(children: [pinAction, editAction, deleteAction])
    }

    private func togglePin(with trackerId: UUID) {
        guard let tracker = categories.flatMap({ $0.trackers }).first(where: { $0.id == trackerId }) else {
            return
        }
        let updatedTracker = Tracker(
            id: tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            isPinned: !tracker.isPinned
        )
        do {
            try trackerStore.update(updatedTracker)
        } catch {
            print("Ошибка при обновлении закрепления трекера: \(error)")
        }
    }

    private func editTracker(with trackerId: UUID) {
        guard let tracker = categories.flatMap({ $0.trackers }).first(where: { $0.id == trackerId }) else {
            return
        }
        
        let categoryTitle = categories.first { category in
            category.trackers.contains { $0.id == trackerId }
        }?.title ?? ""
       
        let completedDays = completedTrackers.filter { $0.trackerId == trackerId }.count
        
        let habitVC = HabitViewController(
            mode: .edit(tracker: tracker, categoryTitle: categoryTitle, completedDays: completedDays),
            coreDataManager: coreDataManager
        )
        habitVC.delegate = self
        let navigationController = UINavigationController(rootViewController: habitVC)
        present(navigationController, animated: true)
    }

    private func deleteTracker(with trackerId: UUID) {
        let alert = UIAlertController(
            title: NSLocalizedString("trackers.delete.alert.title", comment: "Alert title for deleting tracker"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("trackers.context.delete", comment: "Context menu title for deleting tracker"),
            style: .destructive
        ) { [weak self] _ in
            do {
                try self?.trackerStore.delete(trackerId: trackerId)
            } catch {
                print("Ошибка при удалении трекера: \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("categoryList.alert.cancel", comment: "Cancel button title"),
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
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
        reloadCollectionView()
        updateFilterButtonVisibility()
    }
    
    private func reloadCollectionView() {
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        let hasContent = !visibleCategories.isEmpty
        placeholderImageView.isHidden = hasContent
        placeholderLabel.isHidden = hasContent
        collectionView.isHidden = !hasContent
        
        if !hasContent {
            let isFilterActive = !currentFilter.isResetFilter || !searchText.isEmpty
            
            if isFilterActive {
                placeholderImageView.image = UIImage(named: "Nothing was found")
                placeholderLabel.text = NSLocalizedString(
                    "trackers.placeholder.nothingFound",
                    comment: "Nothing found placeholder"
                )
            } else {
                placeholderImageView.image = UIImage(named: "StarCircle")
                placeholderLabel.text = NSLocalizedString(
                    "trackers.placeholder.title",
                    comment: "Placeholder title when there are no trackers"
                )
            }
        }
    }
    
    private func updateFilterButtonVisibility() {
        let hasTrackersOnSelectedDate = hasTrackersOnDate(currentDate)
        let isSearchActive = !searchText.isEmpty
        let hasSearchResults = !visibleCategories.isEmpty
        
        if !hasTrackersOnSelectedDate {
            filterButton.isHidden = true
        } else if isSearchActive && !hasSearchResults {
            filterButton.isHidden = true
        } else {
            filterButton.isHidden = false
        }
    }
    
    private func hasTrackersOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        for category in categories {
            let trackersForDate = category.trackers.filter { tracker in
                tracker.schedule.isEmpty || tracker.schedule.contains(where: { $0.rawValue == weekday })
            }
            if !trackersForDate.isEmpty {
                return true
            }
        }
        return false
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
            let allCategories = try categoryStore.fetchAll()
            let existingCategory = allCategories.first { $0.title == title }
            let categoryId: UUID
            
            if let category = existingCategory {
                categoryId = category.id
            } else {
                categoryId = try categoryStore.add(title: title)
            }
            
            try trackerStore.add(tracker, categoryId: categoryId)
        } catch {
            // Ошибка добавления трекера
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
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        cell.configure(with: tracker, isCompleted: isCompleted, count: completedDays, at: startOfDay)
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
        AnalyticsService.trackButtonClick(screen: Analytics.screenMain, item: Analytics.itemTrack)
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let record = TrackerRecord(trackerId: tracker.id, date: startOfDay)
        
        do {
            if completedTrackers.contains(record) {
                try recordStore.delete(trackerId: tracker.id, date: startOfDay)
                completedTrackers.remove(record)
            } else {
                try recordStore.add(record)
                completedTrackers.insert(record)
            }
            
        } catch {
        }
    }
    
    func didRequestContextMenu(for cell: TrackerCell, at location: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, actionProvider: { [weak self] _ in
            guard let self else { return nil }
            return self.makeContextMenu(for: tracker, at: indexPath)
        })
    }
}

// MARK: - HabitViewControllerDelegate

extension TrackersViewController: HabitViewControllerDelegate {
    func didSaveHabit(_ tracker: Tracker, categoryTitle: String, isNewTracker: Bool) {
        if isNewTracker {
            addTracker(tracker, toCategory: categoryTitle)
        } else {
            do {
                try trackerStore.update(tracker)
                
                if categoryTitle != originalCategoryTitle(for: tracker.id),
                   let newCategory = categories.first(where: { $0.title == categoryTitle }) {
                    try trackerStore.updateCategory(for: tracker.id, newCategoryId: newCategory.id)
                }
            } catch {
                print("Ошибка при обновлении трекера: \(error)")
            }
        }
    }
    
    private func originalCategoryTitle(for trackerId: UUID) -> String {
        return categories.first { category in
            category.trackers.contains { $0.id == trackerId }
        }?.title ?? ""
    }
}

// MARK: - Store Delegates

extension TrackersViewController: TrackerStoreDelegate, TrackerCategoryStoreDelegate {
    func storeDidChange() {
        DispatchQueue.main.async {
            self.loadData()
            UIView.transition(with: self.collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.collectionView.reloadData()
            }, completion: { _ in
                self.updateUI()
            })
        }
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidUpdateRecords(_ store: TrackerRecordStore) {
        DispatchQueue.main.async {
            
            self.loadData()
            self.collectionView.reloadData()
        }
    }
}

// MARK: - Filter Methods

extension TrackersViewController {
    private func loadCurrentFilter() {
        let savedFilterRawValue = UserDefaults.standard.integer(forKey: "currentFilter")
        currentFilter = TrackerFilter(rawValue: savedFilterRawValue) ?? .all
        updateFilterButtonAppearance()
    }
    
    private func saveCurrentFilter() {
        UserDefaults.standard.set(currentFilter.rawValue, forKey: "currentFilter")
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        saveCurrentFilter()
        
        if filter == .today {
            currentDate = Date()
            datePicker.date = Date()
        }
        
        updateFilterButtonAppearance()
        updateUI()
    }
    
    private func updateFilterButtonAppearance() {
        if currentFilter.isResetFilter {
            filterButton.setTitleColor(Colors.buttonText, for: .normal)
        } else {
            filterButton.setTitleColor(.red, for: .normal)
        }
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.trackButtonClick(screen: Analytics.screenMain, item: Analytics.itemFilter)
        
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.selectedFilter = currentFilter
        
        let navController = UINavigationController(rootViewController: filterVC)
        present(navController, animated: true)
    }
}

// MARK: - FilterViewControllerDelegate

extension TrackersViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        applyFilter(filter)
    }
}

// MARK: - Setup Delegates

extension TrackersViewController {
    private func setupDelegates() {
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            searchText = text
        } else {
            searchText = ""
        }
        updateUI()
    }
}
