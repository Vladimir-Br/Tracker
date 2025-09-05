import UIKit

// MARK: - ColorCollectionViewCell

final class ColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "ColorCollectionViewCell"
    
    // MARK: - UI Elements
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = LayoutConstants.cellCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectionBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        view.layer.cornerRadius = LayoutConstants.cellCornerRadius
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    private var color: UIColor = .clear
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(colorView)
        contentView.addSubview(selectionBorderView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: LayoutConstants.cellSize),
            colorView.heightAnchor.constraint(equalToConstant: LayoutConstants.cellSize),
            
            selectionBorderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionBorderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionBorderView.widthAnchor.constraint(equalToConstant: LayoutConstants.cellSize),
            selectionBorderView.heightAnchor.constraint(equalToConstant: LayoutConstants.cellSize)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(with color: UIColor) {
        self.color = color
        colorView.backgroundColor = color
    }
    
    func setSelected(_ selected: Bool) {
        selectionBorderView.isHidden = !selected
        if selected {
            selectionBorderView.layer.borderColor = color.cgColor
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        color = .clear
        colorView.backgroundColor = .clear
        setSelected(false)
    }
}
