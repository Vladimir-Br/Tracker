
import UIKit

// MARK: - EditHabitViewControllerDelegate

protocol EditHabitViewControllerDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker, categoryTitle: String)
}

// MARK: - EditHabitViewController

final class EditHabitViewController: UIViewController {
    
    // MARK: - Properties
    
    private let coreDataManager: CoreDataManager
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    
    weak var delegate: EditHabitViewControllerDelegate?
    
    // MARK: - Edit Mode Properties
    
    private let editingTracker: Tracker
    private let originalCategoryTitle: String
    private let completedDays: Int
    
    private let lightGrayColor = UIColor(resource: .backgroundDay)
    
    // MARK: - Private Properties
    
    private var schedule: [Weekday] = []
    private var selectedCategory: TrackerCategory?
    private var selectedEmoji: String?
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColor: UIColor?
    private var selectedColorIndexPath: IndexPath?
    
    // MARK: - Initialization
    
    init(coreDataManager: CoreDataManager, editingTracker: Tracker, categoryTitle: String, completedDays: Int) {
        self.coreDataManager = coreDataManager
        self.trackerStore = TrackerStore(context: coreDataManager.viewContext)
        self.categoryStore = TrackerCategoryStore(context: coreDataManager.viewContext)
        self.editingTracker = editingTracker
        self.originalCategoryTitle = categoryTitle
        self.completedDays = completedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 22.0 / 16.0
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .kern: 0
        ]
        
        label.attributedText = NSAttributedString(
            string: NSLocalizedString("editHabit.title", comment: "Title for edit habit screen"),
            attributes: attributes
        )
        label.textColor = UIColor(resource: .blackDay)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysCounterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(resource: .blackDay)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString(
            "newHabit.placeholder.name",
            comment: "Placeholder for tracker name field"
        )
        textField.backgroundColor = UIColor(resource: .backgroundDay)
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let menuTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .backgroundDay)
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(
            NSLocalizedString("newHabit.button.cancel", comment: "Cancel button title"),
            for: .normal
        )
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(
            NSLocalizedString("editHabit.saveButton", comment: "Save button title for edit habit"),
            for: .normal
        )
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = LayoutConstants.emojiHorizontalSpacing
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: LayoutConstants.cellSize, height: LayoutConstants.cellSize)
        layout.sectionInset = UIEdgeInsets(
            top: 24,
            left: 0,
            bottom: 24,
            right: 0
        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString(
            "newHabit.section.emoji",
            comment: "Title for emoji selection section"
        )
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(resource: .blackDay)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = LayoutConstants.emojiHorizontalSpacing
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: LayoutConstants.cellSize, height: LayoutConstants.cellSize)
        layout.sectionInset = UIEdgeInsets(
            top: 24,
            left: 0,
            bottom: 24,
            right: 0
        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString(
            "newHabit.section.color",
            comment: "Title for color selection section"
        )
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(resource: .blackDay)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        setupUI()
        setupLayout()
        setupTapGesture()
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        menuTableView.dataSource = self
        menuTableView.delegate = self
        nameTextField.delegate = self
        
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        
        setupEditMode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Обновляем данные после того, как view добавлен в иерархию
        menuTableView.reloadData()
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(daysCounterLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(menuTableView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(saveButton)
        contentView.addSubview(buttonsStackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            daysCounterLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            daysCounterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            daysCounterLabel.heightAnchor.constraint(equalToConstant: 38),
            
            nameTextField.topAnchor.constraint(equalTo: daysCounterLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            menuTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            menuTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            menuTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            menuTableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: menuTableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiLabel.heightAnchor.constraint(equalToConstant: 18),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.emojiLeftInset),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.emojiRightInset),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorLabel.heightAnchor.constraint(equalToConstant: 18),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.emojiLeftInset),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.emojiRightInset),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            buttonsStackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 0),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    private func setupEditMode() {
        // Настраиваем счетчик дней
        daysCounterLabel.text = formatDaysString(for: completedDays)
        
        // Заполняем поля данными редактируемой привычки
        nameTextField.text = editingTracker.name
        selectedEmoji = editingTracker.emoji
        selectedColor = editingTracker.color
        schedule = editingTracker.schedule
        
        // Устанавливаем категорию
        selectedCategory = TrackerCategory(id: UUID(), title: originalCategoryTitle, trackers: [])
        
        // Обновляем UI
        updateEmojiSelection()
        updateColorSelection()
    }
    
    private func formatDaysString(for count: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString(
                "trackerCell.days",
                comment: "Pluralized string describing number of completed days"
            ),
            count
        )
    }
    
    private func updateEmojiSelection() {
        guard let emoji = selectedEmoji,
              let index = EmojiConstants.emojis.firstIndex(of: emoji) else { return }
        selectedEmojiIndexPath = IndexPath(item: index, section: 0)
    }
    
    private func updateColorSelection() {
        guard let color = selectedColor,
              let index = ColorConstants.colors.firstIndex(where: { $0.hexString == color.hexString }) else { return }
        selectedColorIndexPath = IndexPath(item: index, section: 0)
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor,
              let selectedCategory = selectedCategory else { return }
        
        let updatedTracker = Tracker(
            id: editingTracker.id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: editingTracker.isPinned
        )
        
        delegate?.didUpdateTracker(updatedTracker, categoryTitle: selectedCategory.title)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension EditHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = UIColor(resource: .grayDay)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString(
                "newHabit.menu.category",
                comment: "Menu title for category selection"
            )
            cell.detailTextLabel?.text = selectedCategory?.title
        case 1:
            cell.textLabel?.text = NSLocalizedString(
                "newHabit.menu.schedule",
                comment: "Menu title for schedule selection"
            )
            if !schedule.isEmpty {
                let scheduleText = schedule.count == 7
                    ? NSLocalizedString("newHabit.schedule.everyday", comment: "Title for everyday schedule option")
                    : schedule.map { $0.shortTitle }.joined(separator: ", ")
                cell.detailTextLabel?.text = scheduleText
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EditHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let viewModel = CategoryListViewModel(categoryStore: categoryStore)
            
            if let selectedCategory = selectedCategory {
                viewModel.selectCategory(selectedCategory)
            }
            
            let categoryListVC = CategoryListViewController(viewModel: viewModel)
            categoryListVC.delegate = self
            navigationController?.pushViewController(categoryListVC, animated: true)
        case 1:
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.currentlySelectedDays = Set(self.schedule)
            navigationController?.pushViewController(scheduleVC, animated: true)
        default:
            break
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditHabitViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // В режиме редактирования кнопка всегда активна, если есть данные
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ScheduleViewControllerDelegate

extension EditHabitViewController: ScheduleViewControllerDelegate {
    func didConfirmSchedule(selectedDays: Set<Weekday>) {
        self.schedule = Array(selectedDays).sorted(by: { $0.rawValue < $1.rawValue })
        reloadTableViewIfNeeded()
    }
}

// MARK: - CategorySelectionDelegate

extension EditHabitViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        self.selectedCategory = category
        reloadTableViewIfNeeded()
    }
}

// MARK: - UICollectionViewDelegate

extension EditHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexPathsToReload = handleCollectionSelection(collectionView, at: indexPath)
        collectionView.reloadItems(at: indexPathsToReload)
    }
    
    private func handleCollectionSelection(_ collectionView: UICollectionView, at indexPath: IndexPath) -> [IndexPath] {
        var indexPathsToReload: [IndexPath] = []
        
        switch collectionView {
        case emojiCollectionView:
            indexPathsToReload = handleEmojiSelection(at: indexPath)
        case colorCollectionView:
            indexPathsToReload = handleColorSelection(at: indexPath)
        default:
            break
        }
        
        return indexPathsToReload
    }
    
    private func handleEmojiSelection(at indexPath: IndexPath) -> [IndexPath] {
        var indexPathsToReload: [IndexPath] = []
        
        if let previousIndexPath = selectedEmojiIndexPath {
            indexPathsToReload.append(previousIndexPath)
        }
        
        selectedEmojiIndexPath = indexPath
        selectedEmoji = EmojiConstants.emojis[indexPath.item]
        indexPathsToReload.append(indexPath)
        
        return indexPathsToReload
    }
    
    private func handleColorSelection(at indexPath: IndexPath) -> [IndexPath] {
        var indexPathsToReload: [IndexPath] = []
        
        if let previousIndexPath = selectedColorIndexPath {
            indexPathsToReload.append(previousIndexPath)
        }
        
        selectedColorIndexPath = indexPath
        selectedColor = ColorConstants.colors[indexPath.item]
        indexPathsToReload.append(indexPath)
        
        return indexPathsToReload
    }
}

// MARK: - UICollectionViewDataSource

extension EditHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case emojiCollectionView:
            return EmojiConstants.emojis.count
        case colorCollectionView:
            return ColorConstants.colors.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case emojiCollectionView:
            return configureEmojiCell(collectionView, at: indexPath)
        case colorCollectionView:
            return configureColorCell(collectionView, at: indexPath)
        default:
            return UICollectionViewCell()
        }
    }
    
    private func configureEmojiCell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? EmojiCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let emoji = EmojiConstants.emojis[indexPath.item]
        cell.configure(with: emoji)
        cell.setSelected(indexPath == selectedEmojiIndexPath)
        
        return cell
    }
    
    private func configureColorCell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ColorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let color = ColorConstants.colors[indexPath.item]
        cell.configure(with: color)
        cell.setSelected(indexPath == selectedColorIndexPath)
        
        return cell
    }
}

// MARK: - Private Methods

extension EditHabitViewController {
    private func reloadTableViewIfNeeded() {
        // Проверяем, что view находится в иерархии окон
        guard view.window != nil else {
            // Если view не в иерархии, откладываем обновление
            DispatchQueue.main.async {
                self.menuTableView.reloadData()
            }
            return
        }
        
        // Если view в иерархии, обновляем сразу
        menuTableView.reloadData()
    }
}
