
import UIKit

protocol TrackersCellDelegate: AnyObject {
    func completeOrUncompleteTracker(trackerId: UUID,indexPath: IndexPath)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "TrackerCell"
    private var daysCounter: Int = .zero
    var isPinned: Bool = false
    // UI элементы
    let coloredRectangleView = UIView()
    private let emojiLabel = UILabel()
    private let whiteEmojiBackground = UIView()
    private let mainLabel = UILabel()
    private let nonColoredRectangleView = UIView()
    private let daysCounterLabel = UILabel()
    private let coloredCircleButton = UIButton()
    
    // Дополнительные свойства
    weak var delegate: TrackersCellDelegate?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    var date: Date?
    var indexPath: IndexPath?
    
    // Изображения для кнопки
    private let plusImage = UIImage(named: "plus")?.withTintColor(.white) ?? UIImage()
    private let doneImage = UIImage(named: "done")?.withTintColor(.white) ?? UIImage()
    private let pinImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pin.fill")
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Нет инициализации")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Закругление краев
        coloredRectangleView.layer.cornerRadius = 16
        whiteEmojiBackground.layer.cornerRadius = 12
        coloredCircleButton.layer.cornerRadius = 17
    }
    
    private func setupUI() {
        [coloredRectangleView, whiteEmojiBackground, emojiLabel, mainLabel, nonColoredRectangleView, daysCounterLabel, coloredCircleButton, pinImage].forEach {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    contentView.addSubview($0)
                }
        coloredRectangleView.backgroundColor = .blue
        whiteEmojiBackground.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        emojiLabel.font = UIFont.systemFont(ofSize: 13)
        emojiLabel.textAlignment = .center
        
        mainLabel.font = UIFont.systemFont(ofSize: 12)
        mainLabel.numberOfLines = 0
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.textColor = .white
        
        daysCounterLabel.font = UIFont.systemFont(ofSize: 12)
        daysCounterLabel.textAlignment = .left
        
        coloredCircleButton.addTarget(self, action: #selector(coloredCircleButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            coloredRectangleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coloredRectangleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coloredRectangleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coloredRectangleView.heightAnchor.constraint(equalToConstant: 90),
            
            pinImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            pinImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            pinImage.widthAnchor.constraint(equalToConstant: 12),
            pinImage.heightAnchor.constraint(equalToConstant: 12),
            
            whiteEmojiBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            whiteEmojiBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            whiteEmojiBackground.widthAnchor.constraint(equalToConstant: 24),
            whiteEmojiBackground.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: whiteEmojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: whiteEmojiBackground.centerYAnchor),
            
            mainLabel.leadingAnchor.constraint(equalTo: coloredRectangleView.leadingAnchor, constant: 12),
            mainLabel.trailingAnchor.constraint(equalTo: coloredRectangleView.trailingAnchor, constant: -12),
            mainLabel.bottomAnchor.constraint(equalTo: coloredRectangleView.bottomAnchor, constant: -12),
            
            nonColoredRectangleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nonColoredRectangleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nonColoredRectangleView.topAnchor.constraint(equalTo: coloredRectangleView.bottomAnchor),
            nonColoredRectangleView.heightAnchor.constraint(equalToConstant: 58),
            
            coloredCircleButton.trailingAnchor.constraint(equalTo: nonColoredRectangleView.trailingAnchor, constant: -12),
            coloredCircleButton.bottomAnchor.constraint(equalTo: nonColoredRectangleView.bottomAnchor, constant: -16),
            coloredCircleButton.widthAnchor.constraint(equalToConstant: 34),
            coloredCircleButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCounterLabel.centerYAnchor.constraint(equalTo: coloredCircleButton.centerYAnchor),
            daysCounterLabel.leadingAnchor.constraint(equalTo: nonColoredRectangleView.leadingAnchor, constant: 12)
        ])
    }

    func configure(with tracker: TrackerModel, isCompletedToday: Bool, completedDays: Int, indexPath: IndexPath,isPinned: Bool) {
        self.trackerId = tracker.id
        self.indexPath = indexPath
        self.isPinned = isPinned
        self.isCompletedToday = isCompletedToday
        mainLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        pinImage.isHidden = !self.isPinned
        coloredRectangleView.backgroundColor = tracker.color
        updateCircleButton(isCompleted: isCompletedToday)
        daysCounterLabel.text = pluralizeDays(completedDays)
    }
    
    private func updateCircleButton(isCompleted: Bool) {
        let image = isCompleted ? doneImage : plusImage
        coloredCircleButton.setImage(image, for: .normal)
        let alphaValue: CGFloat = isCompleted ? 0.3 : 1.0
        coloredCircleButton.backgroundColor = coloredRectangleView.backgroundColor?.withAlphaComponent(alphaValue)
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "\(count) день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    @objc private func coloredCircleButtonTapped() {
        guard let trackerId = trackerId, let indexPath = indexPath else { return }
        delegate?.completeOrUncompleteTracker(trackerId: trackerId, indexPath: indexPath)
        
    }
    
}
