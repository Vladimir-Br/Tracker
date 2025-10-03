
import UIKit

// MARK: - ScheduleViewControllerDelegate

protocol ScheduleViewControllerDelegate: AnyObject {
    func didConfirmSchedule(selectedDays: Set<Weekday>)
}

// MARK: - ScheduleViewController

final class ScheduleViewController: UIViewController {

    // MARK: - Properties
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    var currentlySelectedDays: Set<Weekday> = []
    
    private let weekDays: [Weekday] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
    ]
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString(
            "schedule.title",
            comment: "Title for schedule selection screen"
        )
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Colors.labelPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduleTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Colors.cellBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(
            NSLocalizedString("schedule.button.done", comment: "Done button title"),
            for: .normal
        )
        button.setTitleColor(Colors.buttonPrimaryText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = Colors.gray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = Colors.background
        
        setupUI()
        setupLayout()
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        checkDoneButtonState()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(scheduleTableView)
        view.addSubview(doneButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scheduleTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
            
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
        doneButton.backgroundColor = isEnabled ? Colors.buttonPrimary : Colors.gray
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
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(currentlySelectedDays.contains(day), animated: false)
        switchView.onTintColor = UIColor(resource: .blueDay) 
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        
        cell.accessoryView = switchView
        
        if indexPath.row == weekDays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
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
