import UIKit

// MARK: - EmojiCollectionViewCell

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "EmojiCollectionViewCell"
    
    // MARK: - UI Elements
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Light Gray")
        view.layer.cornerRadius = 16
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Private Properties
    
    private var emoji: String = ""
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(emojiLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            selectionBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            selectionBackgroundView.heightAnchor.constraint(equalToConstant: 52),
           
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 32),
            emojiLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
    
    private func setupAppearance() {
        contentView.backgroundColor = .clear
    }
    
    // MARK: - Configuration
    
    func configure(with emoji: String) {
        self.emoji = emoji
        emojiLabel.text = emoji
    }
    
    func setSelected(_ selected: Bool) {
        selectionBackgroundView.isHidden = !selected
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        emoji = ""
        emojiLabel.text = ""
        setSelected(false)
    }
}
