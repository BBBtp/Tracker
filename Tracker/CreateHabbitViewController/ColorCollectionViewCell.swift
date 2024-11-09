import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    static let colorIdentifier = "colorCell"
    
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
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize.zero
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size = CGSize(width: 40, height: 40)
    }
}
