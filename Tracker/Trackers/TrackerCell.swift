
import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapCompleteButton(for cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - UI Elements
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysCounterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        
        contentView.addSubview(cardView)
        contentView.addSubview(daysCounterLabel)
        contentView.addSubview(completeButton)
        
        cardView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCounterLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor) 
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with tracker: Tracker, isCompleted: Bool, count: Int, at date: Date) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        daysCounterLabel.text = formatDaysString(for: count)
        
        let buttonImage = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        completeButton.setImage(buttonImage, for: .normal)
        completeButton.tintColor = .white
        completeButton.backgroundColor = tracker.color
        completeButton.alpha = isCompleted ? 0.3 : 1.0
        
        let calendar = Calendar.current
        let isFutureDay = calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
        completeButton.isEnabled = !isFutureDay
    }
    
    // MARK: - Actions
    
    @objc private func completeButtonTapped() {
        delegate?.didTapCompleteButton(for: self)
    }
    
    // MARK: - Helpers
    
    private func formatDaysString(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "\(count) дней"
        } else if lastDigit == 1 {
            return "\(count) день"
        } else if lastDigit >= 2 && lastDigit <= 4 {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
}
