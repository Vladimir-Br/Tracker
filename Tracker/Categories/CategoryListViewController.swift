
import UIKit

// MARK: - CategorySelectionDelegate

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

// MARK: - CategoryListViewController

final class CategoryListViewController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel: CategoryListViewModel?
    weak var delegate: CategorySelectionDelegate?
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(resource: .blackDay)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .starCircle)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\n объединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .blackDay)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [placeholderImageView, placeholderLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(resource: .blackDay)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.loadCategories()
    }
    
    // MARK: - Initialization
    
    func initialize(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(placeholderStackView)
        view.addSubview(addCategoryButton)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 84),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Binding (MVVM Pattern)
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.onCategoriesDidChange = { [weak self] categories in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onEmptyStateDidChange = { [weak self] isEmpty in
            DispatchQueue.main.async {
                self?.updatePlaceholderVisibility(isEmpty: isEmpty)
            }
        }
        
        viewModel.onErrorStateChange = { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let message = errorMessage {
                    self?.showErrorAlert(message: message)
                }
            }
        }
        
        viewModel.onSelectedCategoryDidChange = { [weak self] selectedCategory in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updatePlaceholderVisibility(isEmpty: Bool) {
        placeholderStackView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfCategories ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as? CategoryTableViewCell,
              let viewModel = viewModel,
              let category = viewModel.category(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        let isSelected = viewModel.isSelected(category: category)
        cell.configure(with: category, isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let viewModel = viewModel,
              let category = viewModel.category(at: indexPath.row) else { return }
        
        viewModel.selectCategory(category)
        
        delegate?.didSelectCategory(category)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let categoryCell = cell as? CategoryTableViewCell,
              let viewModel = viewModel else { return }
        
        let numberOfRows = viewModel.numberOfCategories
        var corners: CACornerMask = []
        
        if indexPath.row == 0 {
            corners.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner])
        }
        
        if indexPath.row == numberOfRows - 1 {
            corners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            categoryCell.hideSeparator()
        } else {
            categoryCell.showSeparator()
        }
       
        cell.layer.maskedCorners = corners
        cell.layer.cornerRadius = !corners.isEmpty ? 16 : 0
        cell.layer.masksToBounds = !corners.isEmpty
        cell.backgroundColor = UIColor(resource: .backgroundDay)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            return self?.createContextMenu(for: indexPath)
        }
    }
    
    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] _ in
            self?.editCategory(at: indexPath)
        }
        
        let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.showDeleteConfirmation(for: indexPath)
        }
        
        return UIMenu(children: [editAction, deleteAction])
    }
    
    private func editCategory(at indexPath: IndexPath) {
        guard let viewModel = viewModel,
              let category = viewModel.category(at: indexPath.row) else { return }
        
        viewModel.selectCategory(category)
        let editCategoryVC = NewCategoryViewController()
        editCategoryVC.configure(for: .edit(category: category, index: indexPath.row))
        editCategoryVC.delegate = self
        
        let navigationController = UINavigationController(rootViewController: editCategoryVC)
        present(navigationController, animated: true)
    }
    
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        guard let viewModel = viewModel,
              let category = viewModel.category(at: indexPath.row) else { return }
        
        viewModel.selectCategory(category)
        
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel?.deleteCategory(at: indexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - NewCategoryViewControllerDelegate

extension CategoryListViewController: NewCategoryViewControllerDelegate {
    func didCreateCategory(_ title: String) {
        viewModel?.addCategory(title: title)
    }
    
    func didUpdateCategory(_ title: String, at index: Int) {
        viewModel?.updateCategory(at: index, newTitle: title)
    }
}
