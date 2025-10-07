
import UIKit

// MARK: - StatisticsCell

final class StatisticsCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "StatisticsCell"
    
    // MARK: - UI Elements
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = Colors.labelPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Colors.labelPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientBorderLayer = CAGradientLayer()
    private let borderShapeLayer = CAShapeLayer()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupCell()
        self.setupConstraints()
        self.setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateGradientBorderFrame()
    }
    
    // MARK: - Configuration
    
    func configure(with item: StatisticsItem) {
        self.valueLabel.text = "\(item.value)"
        self.titleLabel.text = item.title
    }
}

// MARK: - Private Methods

private extension StatisticsCell {
    
    func setupCell() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = Colors.background
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        
        self.contentView.addSubview(self.valueLabel)
        self.contentView.addSubview(self.titleLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.valueLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            self.valueLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12),
            self.valueLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.valueLabel.bottomAnchor, constant: 7),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12),
            self.titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func setupGradientBorder() {
        self.gradientBorderLayer.colors = [
            UIColor(red: 0.00, green: 0.48, blue: 0.98, alpha: 1.0).cgColor,
            UIColor(red: 0.27, green: 0.90, blue: 0.62, alpha: 1.0).cgColor,
            UIColor(red: 0.99, green: 0.30, blue: 0.29, alpha: 1.0).cgColor
        ]
        self.gradientBorderLayer.startPoint = CGPoint(x: 1, y: 0.5)
        self.gradientBorderLayer.endPoint = CGPoint(x: 0, y: 0.5)
        
        self.borderShapeLayer.lineWidth = 1
        self.borderShapeLayer.fillColor = UIColor.clear.cgColor
        self.borderShapeLayer.strokeColor = UIColor.black.cgColor
        
        self.gradientBorderLayer.mask = self.borderShapeLayer
        self.contentView.layer.addSublayer(self.gradientBorderLayer)
    }
    
    func updateGradientBorderFrame() {
        self.gradientBorderLayer.frame = self.contentView.bounds
        
        let path = UIBezierPath(
            roundedRect: self.contentView.bounds,
            cornerRadius: 16
        )
        self.borderShapeLayer.path = path.cgPath
    }
}

