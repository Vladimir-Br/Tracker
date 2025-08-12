
import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didConfirmSchedule(selectedDays: Set<Tracker.Weekday>)
}

final class ScheduleViewController: UIViewController {
    
    // MARK: - Delegate
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    // MARK: - Properties
    
    
    var currentlySelectedDays: Set<Tracker.Weekday> = []
    private let weekDays = Tracker.Weekday.allCases
    
    // MARK: - UI Elements
    
    private let scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Расписание"
        view.backgroundColor = .white
        
        setupUI()
        setupLayout()
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        checkDoneButtonState()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scheduleTableView)
        view.addSubview(doneButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            scheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525), // 7 ячеек по 75
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func switchToggled(_ sender: UISwitch) {
        
        let day = weekDays[sender.tag]
        
        if sender.isOn {
            currentlySelectedDays.insert(day)
        } else {
            currentlySelectedDays.remove(day)
        }
        
        checkDoneButtonState()
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didConfirmSchedule(selectedDays: currentlySelectedDays)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func checkDoneButtonState() {
        let isEnabled = !currentlySelectedDays.isEmpty
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled ? .black : .gray
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let day = weekDays[indexPath.row]
        cell.textLabel?.text = day.title
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.12)
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(currentlySelectedDays.contains(day), animated: false)
        switchView.onTintColor = .systemBlue
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        if indexPath.row == weekDays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
