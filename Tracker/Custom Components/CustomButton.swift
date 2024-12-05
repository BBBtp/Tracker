//
//  CustomButton.swift
//  Tracker
//
//  Created by Богдан Топорин on 03.12.2024.
//

import UIKit
import Foundation

enum ButtonTypeCustom {
    case create, reject
}

class CustomButton: UIButton {
    init(type: ButtonTypeCustom, title: String) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        configureButton(for: type)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureButton(for type: ButtonTypeCustom) {
        switch type {
        case .create:
            self.backgroundColor = .ypBlack
            self.layer.cornerRadius = 16
            self.setTitleColor(.ypWhite, for: .normal)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
           
        case .reject:
            self.backgroundColor = .ypWhite
            self.setTitleColor(.red, for: .normal)
            self.layer.borderColor = UIColor.red.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 16
            self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        self.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        if self.backgroundColor == .ypBlack {
            sender.backgroundColor = .darkGray
        } else {
            sender.backgroundColor = .red
            sender.setTitleColor(.ypWhite, for: .normal)
        }
    }
    
    @objc private func buttonReleased(_ sender: UIButton) {
        if self.backgroundColor == .darkGray {
            sender.backgroundColor = .ypBlack
        } else {
            sender.backgroundColor = .ypWhite
            sender.setTitleColor(.red, for: .normal)
        }
    }
}

class FilterButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        configureButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureButton() {
            self.backgroundColor = .ypBlue
            self.layer.cornerRadius = 16
            self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
        self.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        if self.backgroundColor == .ypBlue {
            sender.backgroundColor = UIColor.ypBlue.withAlphaComponent(0.5)
        }
    }
    
    @objc private func buttonReleased(_ sender: UIButton) {
        if self.backgroundColor == UIColor.ypBlue.withAlphaComponent(0.5) {
            sender.backgroundColor = .ypBlue
        }
    }
}
