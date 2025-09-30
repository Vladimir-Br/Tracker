
import UIKit

// MARK: - FilterViewControllerDelegate

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

// MARK: - FilterViewController

final class FilterViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: FilterViewControllerDelegate?
    var selectedFilter: TrackerFilter = .all
    
    // MARK: - Private UI Elements
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .backgroundDay)
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        return tableView
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
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("filters.button.title", comment: "Filters button title")
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(resource: .blackDay)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseIdentifier)
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        guard let titleLabel = view.subviews.first(where: { $0 is UILabel }) else { return }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300) 
        ])
    }
}

// MARK: - UITableViewDataSource

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
        let filter = TrackerFilter.allCases[indexPath.row]
        let isSelected = filter == selectedFilter
        
        cell.configure(with: filter, isSelected: isSelected)
        
        if indexPath.row == TrackerFilter.allCases.count - 1 {
            cell.hideSeparator() 
        } else {
            cell.showSeparator()
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFilter = TrackerFilter.allCases[indexPath.row]
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
}
