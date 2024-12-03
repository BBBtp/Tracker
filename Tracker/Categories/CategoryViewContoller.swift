//
//  CategoryViewContoller.swift
//  Tracker
//
//  Created by Богдан Топорин on 03.12.2024.
//

import Foundation
import UIKit

final class CategoryViewContoller: UIViewController {
    
    private var selectedCategory: String
    private var viewModel = CategoryViewModel()
    private let cellIdentifier = "CategoriesCell"
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(selectedCategory: String, returnCategory: @escaping ((String) -> Void)) {
        self.selectedCategory = selectedCategory
        
        super.init(nibName: nil, bundle: nil)
        bind(returnCategory)
    }
    
    private func bind(_ returnCategory: @escaping ((String) -> Void)) {
        viewModel.returnCategory = { category in
            returnCategory(category)
        }
        
        viewModel.updateCategories = { [weak self] _ in
            self?.tableView.reloadData()
            self?.setupPlaceholder()
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var createCategoryButton: CustomButton = {
        let button = CustomButton(type: .create, title: "Добавить категорию")
        button.addTarget(self, action: #selector(createCategory), for: .touchUpInside)
        return button
    }()
    
    private var placeholderImageView = UIImageView(image: UIImage(named: "place"))
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    @objc private func createCategory() {
        let viewController = NewCategoryViewController(updateCategories: viewModel.addNewCategory)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(createCategoryButton)
        setupNavigationBar(title: "Категория")
        createPlaceholder()
        setupConstraints()
        setupPlaceholder()
        
    }
}

extension CategoryViewContoller: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.getCategory(at: indexPath)
        cell.configure(title: category, isSelected: category == selectedCategory)
        
        cell.hideSeparator(isLastCell: indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1)
        
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        
        
        if numberOfRows == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == numberOfRows - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
}

extension CategoryViewContoller: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(at: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}

extension CategoryViewContoller {
    private func setupPlaceholder() {
        tableView.isHidden = viewModel.categoriesIsEmpty
        placeholderLabel.isHidden = !viewModel.categoriesIsEmpty
        placeholderImageView.isHidden = !viewModel.categoriesIsEmpty
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor, constant: -16),
            
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createPlaceholder() {
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -50),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80)
        ])
    }
}
