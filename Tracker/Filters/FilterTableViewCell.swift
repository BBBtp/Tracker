//
//  FilterTableViewCell.swift
//  Tracker
//
//  Created by Богдан Топорин on 04.12.2024.
//

import Foundation
import UIKit

final class FilterCell: UITableViewCell {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let isSelectedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .ypBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .ypWhite

        contentView.addSubview(nameLabel)
        contentView.addSubview(isSelectedImage)
        contentView.addSubview(separatorLine)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: isSelectedImage.leadingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            isSelectedImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            isSelectedImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            isSelectedImage.widthAnchor.constraint(equalToConstant: 24),
            isSelectedImage.heightAnchor.constraint(equalToConstant: 24),
            
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, isSelected: Bool) {
        nameLabel.text = name
        isSelectedImage.isHidden = !isSelected
    }
    
    func hideSeparator(isLastCell: Bool) {
        separatorLine.isHidden = isLastCell
    }
}



