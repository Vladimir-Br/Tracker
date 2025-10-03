
import UIKit

// MARK: - NewCategoryViewControllerDelegate

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(_ title: String)
    func didUpdateCategory(_ title: String, at index: Int)
}

// MARK: - CategoryMode

enum CategoryMode {
    case create
    case edit(category: TrackerCategory, index: Int)
}

// MARK: - NewCategoryViewController

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: NewCategoryViewControllerDelegate?
    private var mode: CategoryMode = .create
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Colors.labelPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textFieldContainer: UIView = {
        let container = UIView()
        container.backgroundColor = Colors.cellBackground
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString(
            "newCategory.placeholder",
            comment: "Placeholder for category name field"
        )
        textField.font = .systemFont(ofSize: 17)
        textField.textColor = Colors.labelPrimary
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
       
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(
            NSLocalizedString("newCategory.button.done", comment: "Done button title"),
            for: .normal
        )
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(resource: .grayDay)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupUI()
        setupLayout()
        setupTapGesture()
        
        nameTextField.becomeFirstResponder()
        updateClearButtonVisibility()
    }
    
    // MARK: - Configuration
    
    func configure(for mode: CategoryMode) {
        self.mode = mode
        
        switch mode {
        case .create:
            titleLabel.text = NSLocalizedString(
                "newCategory.title.create",
                comment: "Title for creating new category"
            )
        case .edit(let category, _):
            titleLabel.text = NSLocalizedString(
                "newCategory.title.edit",
                comment: "Title for editing category"
            )
            nameTextField.text = category.title
            updateDoneButtonState()
            updateClearButtonVisibility()
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = Colors.background
        titleLabel.text = NSLocalizedString(
            "newCategory.title.create",
            comment: "Default title for new category screen"
        )
        
        view.addSubview(titleLabel)
        view.addSubview(textFieldContainer)
        textFieldContainer.addSubview(nameTextField)
        view.addSubview(errorLabel)
        view.addSubview(doneButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            textFieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 75),
            
            nameTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            nameTextField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Private Methods
    
    private func updateDoneButtonState() {
        let trimmedText = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isTextValid = !trimmedText.isEmpty && trimmedText.count <= 38
        var shouldEnable = isTextValid
        if case .edit(let category, _) = mode {
            shouldEnable = isTextValid && trimmedText != category.title
        }
        
        doneButton.isEnabled = shouldEnable
        doneButton.backgroundColor = shouldEnable ? UIColor(resource: .blackDay) : UIColor(resource: .grayDay)
        
        let text = nameTextField.text ?? ""
        if text.count > 38 {
            showError(
                NSLocalizedString(
                    "newCategory.error.limit",
                    comment: "Error message when category name exceeds limit"
                )
            )
        } else {
            hideError()
        }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func hideError() {
        errorLabel.isHidden = true
        errorLabel.text = nil
    }
    
    private func updateClearButtonVisibility() {
       
        if case .edit = mode {
            let hasText = !(nameTextField.text?.isEmpty ?? true)
            nameTextField.clearButtonMode = hasText ? .always : .never
        } else {
            nameTextField.clearButtonMode = .never
        }
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        guard let text = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        switch mode {
        case .create:
            delegate?.didCreateCategory(text)
        case .edit(_, let index):
            delegate?.didUpdateCategory(text, at: index)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateDoneButtonState()
        updateClearButtonVisibility()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if doneButton.isEnabled {
            doneButtonTapped()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 39
    }
}
