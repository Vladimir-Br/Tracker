import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Static Properties

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yy" // Наш кастомный формат даты
        return formatter
    }()
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(red: 0.1, green: 0.105, blue: 0.133, alpha: 1) // #1A1B22
        label.text = "Трекеры"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.alpha = 0.011
        return picker
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        button.tintColor = UIColor(red: 0.1, green: 0.105, blue: 0.133, alpha: 1) // #1A1B22
        return button
    }()
    
    private let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        let placeholderText = "Поиск"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1), // #AEAFB4
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        textField.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StarCicrle")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.1, green: 0.105, blue: 0.133, alpha: 1) // #1A1B22
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        
        updateDateLabel(with: datePicker.date)
    }

    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = addButton
        
        let dateContainerView = UIView()
        dateContainerView.translatesAutoresizingMaskIntoConstraints = false
        dateContainerView.addSubview(dateLabel)
        dateContainerView.addSubview(datePicker)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateContainerView)
        
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }

    private func setupLayout() {
        
        guard let dateContainerView = navigationItem.rightBarButtonItem?.customView else { return }
        
        NSLayoutConstraint.activate([
            
            dateLabel.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: dateContainerView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: dateContainerView.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: dateContainerView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: dateContainerView.bottomAnchor),

            dateContainerView.widthAnchor.constraint(equalToConstant: 77),
            dateContainerView.heightAnchor.constraint(equalToConstant: 34),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        print("Нажата кнопка добавления")
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        updateDateLabel(with: selectedDate)
        
        print("Выбрана новая дата: \(selectedDate)")
    }
    
    // MARK: - Private Methods
    
    private func updateDateLabel(with date: Date) {
        dateLabel.text = Self.dateFormatter.string(from: date)
    }
}
