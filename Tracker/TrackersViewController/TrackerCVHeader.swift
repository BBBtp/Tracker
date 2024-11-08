
//
//  TrackerCVHeader.swift
//  TrackerApp
//
//  Created by Гена Утин on 10.10.2024.
//
import UIKit

final class TrackerCVHeader: UICollectionReusableView {
    static let headerIdentifier = "TrackerViewHeader"
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.font = UIFont(name: "SF Pro", size: 19)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
