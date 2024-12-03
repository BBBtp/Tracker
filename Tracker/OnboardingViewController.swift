//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Богдан Топорин on 02.12.2024.
//

import Foundation
import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private let stateStorage = StateStorage()
    init() {
            super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    private lazy var createButton: CustomButton  = {
        let button = CustomButton(type: .create, title: "Вот это технологии!")
        button.addTarget(self, action: #selector(showApplication), for: .touchUpInside)
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private func createLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    
    private func createPages(backgroundImageName: String, textLabel: String) -> UIViewController {
        let page = UIViewController()
        
        if let background = UIImage(named: backgroundImageName) {
            let backgroundView = UIImageView(frame: UIScreen.main.bounds)
            backgroundView.image = background
            backgroundView.contentMode = .scaleAspectFill
            
            let label = createLabel(with: textLabel)
            
            page.view.addSubview(backgroundView)
            page.view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: page.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: page.view.centerYAnchor, constant: 60),
                label.trailingAnchor.constraint(equalTo: page.view.trailingAnchor, constant: -16),
                label.leadingAnchor.constraint(equalTo: page.view.leadingAnchor, constant: 16)
            ])
        }
        return page
    }
    
    private lazy var pages: [UIViewController] = {
        return [
            createPages(backgroundImageName: "back1", textLabel: "Отслеживайте только то, что хотите"),
            createPages(backgroundImageName: "back2", textLabel: "Даже если это не литры воды и йога")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        
        view.addSubview(pageControl)
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168),
            createButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 24),
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return nil
        }
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

extension OnboardingViewController {
    @objc private func showApplication() {
        stateStorage.viewState = true
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }
        let tabBarController = sceneDelegate.setupTabBarController()
        sceneDelegate.window?.rootViewController = tabBarController
        UIView.transition(with: sceneDelegate.window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
