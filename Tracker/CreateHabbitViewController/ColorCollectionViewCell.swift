import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    static let colorIdentifier = "colorCell"
    
    private let innerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        layer.cornerRadius = 8
        layer.masksToBounds = false
        innerView.layer.cornerRadius = 8
        innerView.layer.masksToBounds = true
        contentView.addSubview(innerView)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            innerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            innerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            innerView.widthAnchor.constraint(equalToConstant: 40),
            innerView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size = CGSize(width: 50, height: 50)
    }
    
    func configure(with color: UIColor) {
        innerView.backgroundColor = color
    }
    
    func selectCell() {
        layer.borderWidth = 3
        layer.borderColor = innerView.backgroundColor?.withAlphaComponent(0.3).cgColor
    }
    
    func deselectCell() {
        layer.borderWidth = 0
    }
}
