//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Богдан Топорин on 28.10.2024.
//

import Foundation
import UIKit


final class StatisticsViewController: UIViewController {
    // MARK: - Private Properties
    
    private lazy var containerViewCompleted: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var containerViewBest: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var containerViewPerfect: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var containerViewAverage: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gradientLayer = CAGradientLayer()
    
    private lazy var bestStreakLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bestStreakNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    private lazy var perfectDaysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var perfectDaysNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var averageCompletionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var averageCompletionNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completedNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completedCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyView: PlaceholderEmptyView = {
        let emptyView = PlaceholderEmptyView(frame: .zero)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        return emptyView
    }()
    
    private let statisticsService: StatisticsServiceProtocol = StatisticsService()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        updateContent()
        NotificationCenter.default.addObserver(self, selector: #selector(updateContent), name: .trackerCompletionUpdated, object: nil)
    }
    
    deinit {
            // Отписка от уведомления
            NotificationCenter.default.removeObserver(self, name: .trackerCompletionUpdated, object: nil)
        }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        [containerViewCompleted, containerViewBest, containerViewPerfect, containerViewAverage].forEach {
            setupGradientBorder(for: $0)
        }
    }
    
    
    // MARK: - Public Methods
    
    @objc func updateContent() {
        let numberOfCompleted = statisticsService.numberOfCompleted
        let bestStreak = statisticsService.bestStreak
        let perfectDays = statisticsService.perfectDays
        let averageCompletion = statisticsService.averageCompletion

        containerViewCompleted.isHidden = numberOfCompleted == 0
        emptyView.isHidden = numberOfCompleted > 0

        if numberOfCompleted == 0 {
            let caption = NSLocalizedString("emptyStateNoStatisticsCaption",
                                            comment: "Caption when there are no statistics yet")
            let image = UIImage(named: "emoji2")
            emptyView.config(with: caption, image: image)
        } else {
            completedNumberLabel.text = String(numberOfCompleted)
            completedCaptionLabel.text = String(format: NSLocalizedString("trackers.completedCount",
                                                                          comment: "Number of completed trackers"), numberOfCompleted)
            bestStreakNumberLabel.text = String(bestStreak)
            bestStreakLabel.text = String(format: NSLocalizedString("bestDays", comment: "Best streak of completed days"))
            perfectDaysNumberLabel.text = String(perfectDays)
            perfectDaysLabel.text = String(format: NSLocalizedString("perfectDays", comment: "Number of perfect days"))
            averageCompletionNumberLabel.text = String(averageCompletion)
            averageCompletionLabel.text = String(format: NSLocalizedString("average", comment: "Average completion per day"))
        }
    }

    
    // MARK: - Private Methods
    
    private func setupViews() {
        [emptyView,containerViewCompleted,containerViewBest,containerViewPerfect,containerViewAverage].forEach {
            view.addSubview($0)
        }
        [completedNumberLabel,completedCaptionLabel].forEach {
            containerViewCompleted.addSubview($0)
        }
        [bestStreakNumberLabel,bestStreakLabel].forEach {
            containerViewBest.addSubview($0)
        }
        [perfectDaysNumberLabel,perfectDaysLabel].forEach {
            containerViewPerfect.addSubview($0)
        }
        [averageCompletionNumberLabel,averageCompletionLabel].forEach {
            containerViewAverage.addSubview($0)
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("statisticsTabBarTitle", comment: "Title for the Statistics tab")
        
        view.backgroundColor = .white
    }

    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            containerViewCompleted.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerViewCompleted.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerViewCompleted.topAnchor.constraint(equalTo: view.topAnchor,constant: 250),
            containerViewCompleted.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            containerViewBest.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerViewBest.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerViewBest.topAnchor.constraint(equalTo: containerViewCompleted.bottomAnchor,constant: 12),
            containerViewBest.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            containerViewPerfect.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerViewPerfect.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerViewPerfect.topAnchor.constraint(equalTo: containerViewBest.bottomAnchor,constant: 12),
            containerViewPerfect.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            containerViewAverage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerViewAverage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerViewAverage.topAnchor.constraint(equalTo: containerViewPerfect.bottomAnchor,constant: 12),
            containerViewAverage.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            
            
            completedNumberLabel.leadingAnchor.constraint(equalTo: containerViewCompleted.leadingAnchor, constant: 12),
            completedNumberLabel.trailingAnchor.constraint(equalTo: containerViewCompleted.trailingAnchor, constant: -12),
            completedNumberLabel.topAnchor.constraint(equalTo: containerViewCompleted.topAnchor, constant: 12),
            
            completedCaptionLabel.leadingAnchor.constraint(equalTo: containerViewCompleted.leadingAnchor, constant: 12),
            completedCaptionLabel.trailingAnchor.constraint(equalTo: containerViewCompleted.trailingAnchor, constant: -12),
            completedCaptionLabel.topAnchor.constraint(equalTo: completedNumberLabel.bottomAnchor, constant: 7),
            
            bestStreakNumberLabel.leadingAnchor.constraint(equalTo: containerViewBest.leadingAnchor, constant: 12),
            bestStreakNumberLabel.trailingAnchor.constraint(equalTo: containerViewBest.trailingAnchor, constant: -12),
            bestStreakNumberLabel.topAnchor.constraint(equalTo: containerViewBest.topAnchor, constant: 12),
            
            bestStreakLabel.leadingAnchor.constraint(equalTo: containerViewBest.leadingAnchor, constant: 12),
            bestStreakLabel.trailingAnchor.constraint(equalTo: containerViewBest.trailingAnchor, constant: -12),
            bestStreakLabel.topAnchor.constraint(equalTo: bestStreakNumberLabel.bottomAnchor, constant: 7),
            
            perfectDaysNumberLabel.leadingAnchor.constraint(equalTo: containerViewPerfect.leadingAnchor, constant: 12),
            perfectDaysNumberLabel.trailingAnchor.constraint(equalTo: containerViewPerfect.trailingAnchor, constant: -12),
            perfectDaysNumberLabel.topAnchor.constraint(equalTo: containerViewPerfect.topAnchor, constant: 12),
            
            perfectDaysLabel.leadingAnchor.constraint(equalTo: containerViewPerfect.leadingAnchor, constant: 12),
            perfectDaysLabel.trailingAnchor.constraint(equalTo: containerViewPerfect.trailingAnchor, constant: -12),
            perfectDaysLabel.topAnchor.constraint(equalTo: perfectDaysNumberLabel.bottomAnchor, constant: 7),
            
            averageCompletionNumberLabel.leadingAnchor.constraint(equalTo: containerViewAverage.leadingAnchor, constant: 12),
            averageCompletionNumberLabel.trailingAnchor.constraint(equalTo: containerViewAverage.trailingAnchor, constant: -12),
            averageCompletionNumberLabel.topAnchor.constraint(equalTo: containerViewAverage.topAnchor, constant: 12),
            averageCompletionLabel.leadingAnchor.constraint(equalTo: containerViewAverage.leadingAnchor, constant: 12),
            averageCompletionLabel.trailingAnchor.constraint(equalTo: containerViewAverage.trailingAnchor, constant: -12),
            averageCompletionLabel.topAnchor.constraint(equalTo: averageCompletionNumberLabel.bottomAnchor, constant: 7),
        ])
    }

    
    private func setupGradientBorder(for container: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(named: "YP Color 1")?.cgColor ?? UIColor(),
            UIColor(named: "YP Color 18")?.cgColor ?? UIColor(),
            UIColor(named: "YP Color 3")?.cgColor ?? UIColor()
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = container.bounds
        
        let path = UIBezierPath(roundedRect: container.bounds.insetBy(dx: 1, dy: 1),
                                cornerRadius: container.layer.cornerRadius)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1
        
        gradientLayer.mask = shapeLayer
        container.layer.addSublayer(gradientLayer)
    }

}

