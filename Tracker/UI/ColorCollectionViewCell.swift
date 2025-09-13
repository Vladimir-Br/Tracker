
import UIKit
import CoreData

final class ColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    static let reuseIdentifier = "ColorCollectionViewCell"
    
    // MARK: - UI Elements
    
    private let outerFrameView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 11
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        
        contentView.addSubview(outerFrameView)
        contentView.addSubview(whiteBackgroundView)
        contentView.addSubview(colorView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            outerFrameView.widthAnchor.constraint(equalToConstant: 52),
            outerFrameView.heightAnchor.constraint(equalToConstant: 52),
            outerFrameView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            outerFrameView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            whiteBackgroundView.widthAnchor.constraint(equalToConstant: 46),
            whiteBackgroundView.heightAnchor.constraint(equalToConstant: 46),
            whiteBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            whiteBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(with color: UIColor) {
        
        colorView.backgroundColor = color
        outerFrameView.backgroundColor = color.withAlphaComponent(0.3)
    }
    
    func setSelected(_ selected: Bool) {
        
        outerFrameView.isHidden = !selected
        whiteBackgroundView.isHidden = !selected
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected(false)
    }
}
