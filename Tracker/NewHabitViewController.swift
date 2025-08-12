
import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String)
}

final class NewHabitViewController: UIViewController {
    
    // MARK: - Delegate
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var schedule: [Tracker.Weekday] = []
    
    // MARK: - UI Elements
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.12)
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let menuTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Новая привычка"
        view.backgroundColor = .white
        
        setupUI()
        setupLayout()
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        menuTableView.dataSource = self
        menuTableView.delegate = self
        nameTextField.delegate = self
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(nameTextField)
        view.addSubview(menuTableView)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        view.addSubview(buttonsStackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            menuTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuTableView.heightAnchor.constraint(equalToConstant: 150), // 2 ячейки по 75
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        // Временные хардкод-значения - 14-й спринт
        let emoji = "🙂"
        let color = UIColor.systemBlue
        
        let newTracker = Tracker(
            name: name,
            color: color,
            emoji: emoji,
            schedule: self.schedule
        )
        
        delegate?.didCreateTracker(newTracker, categoryTitle: "Важное")
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func checkCreateButtonState() {
        let isNameEntered = !(nameTextField.text?.isEmpty ?? true)
        let isScheduleSelected = !schedule.isEmpty
        let isEnabled = isNameEntered && isScheduleSelected
        
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .black : .gray
    }
}

// MARK: - UITableViewDataSource

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.12)
        cell.textLabel?.font = .systemFont(ofSize: 17)
        
        // Настройка ячеек
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
        case 1:
            cell.textLabel?.text = "Расписание"
            
        default:
            break
        }
        
        if indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.currentlySelectedDays = Set(self.schedule)
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension NewHabitViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkCreateButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ScheduleViewControllerDelegate

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didConfirmSchedule(selectedDays: Set<Tracker.Weekday>) {
        
        self.schedule = Array(selectedDays).sorted(by: { $0.rawValue < $1.rawValue })
        checkCreateButtonState()
        
        menuTableView.reloadData()
    }
}
