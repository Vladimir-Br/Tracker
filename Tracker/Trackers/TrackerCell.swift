
import UIKit

// MARK: - TrackerCellDelegate

protocol TrackerCellDelegate: AnyObject {
    func didTapCompleteButton(for cell: TrackerCell)
    func didRequestContextMenu(for cell: TrackerCell, at location: CGPoint) -> UIContextMenuConfiguration?
}

// MARK: - TrackerCell

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    private var trackerId: UUID?
    
    // MARK: - UI Elements
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
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
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        contentView.addSubview(cardView)
        contentView.addSubview(daysCounterLabel)
        contentView.addSubview(completeButton)
        
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        cardView.addSubview(pinImageView)
        
        // Добавляем контекстное меню только к cardView
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        cardView.addInteraction(contextMenuInteraction)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
           
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: emojiBackgroundView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            pinImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
            pinImageView.heightAnchor.constraint(equalToConstant: 24),

            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCounterLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(with tracker: Tracker, isCompleted: Bool, count: Int, at date: Date) {
        self.trackerId = tracker.id
        
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        daysCounterLabel.text = formatDaysString(for: count)
        
        let buttonImage = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        completeButton.setImage(buttonImage, for: .normal)
        completeButton.tintColor = .white
        completeButton.backgroundColor = tracker.color
        completeButton.alpha = isCompleted ? 0.3 : 1.0
        completeButton.imageView?.contentMode = .scaleAspectFit
        completeButton.imageEdgeInsets = UIEdgeInsets(top: 11.5, left: 11.5, bottom: 11.5, right: 11.5)
        
        let calendar = Calendar.current
        let isFutureDay = calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
        completeButton.isEnabled = !isFutureDay

        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let paletteConfiguration = UIImage.SymbolConfiguration(paletteColors: [UIColor.white, tracker.color])
        let combinedConfiguration = symbolConfiguration.applying(paletteConfiguration)
        pinImageView.preferredSymbolConfiguration = combinedConfiguration
        pinImageView.image = UIImage(systemName: "pin.square.fill")?.withConfiguration(combinedConfiguration)
        pinImageView.isHidden = !tracker.isPinned
    }

    
    // MARK: - Actions
    
    @objc private func completeButtonTapped() {
        delegate?.didTapCompleteButton(for: self)
    }
    
    // MARK: - Private Methods
    
    private func formatDaysString(for count: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString(
                "trackerCell.days",
                comment: "Pluralized string describing number of completed days"
            ),
            count
        )
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        return delegate?.didRequestContextMenu(for: self, at: location)
    }
}
