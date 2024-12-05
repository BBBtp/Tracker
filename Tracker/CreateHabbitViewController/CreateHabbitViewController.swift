//
//  SheduleViewController.swift
//  Tracker
//
//  Created by Богдан Топорин on 31.10.2024.
//

import Foundation

import UIKit

protocol CreateHabbitDelegate: AnyObject {
    func didCreateHabbit(name: String, days: [WeekDay], color: UIColor, emoji: String, category: String)
    func didCreateIrregularEvent(name: String,days: [WeekDay], color: UIColor,emoji:String,category: String)
    func didUpdateHabbit(id: UUID,name: String, days: [WeekDay], color: UIColor, emoji: String, category: String)
    func didUpdateIrregularEvent(id: UUID,name: String, days: [WeekDay], color: UIColor, emoji: String, category: String)
}

final class CreateHabbitViewController: UIViewController, UITextFieldDelegate {
    private let sheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "customCell")
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .ypShedule
        return tableView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let inputNameCategory = UITextField()
    weak var createHabbitDelegate: CreateHabbitDelegate?
    
    
    private var parameters: GeometricParameters
    
    private lazy var warningLabel: UILabel =  {
        let label = UILabel()
        label.text = String(
            format: NSLocalizedString(
                "warningLabel",
                comment: "Limit charaters"
            ),
            38
        )
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 17 ,weight: .regular)
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = String(
            format: NSLocalizedString(
                "numberOfDays",
                comment: "Number of days"
            ),
            numberOfCompletions
        )
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var emojiCollectionView: UICollectionView!
    private var colorCollectionView: UICollectionView!
    private var isNew: Bool
    var numberOfCompletions: Int = 0
    var selectedWeekDays: [WeekDay] = []
    var trackerName: String = ""
    var isHabitOrRegular = false
    var category: String = ""
    var trackerColor =  UIColor.clear
    var trackerEmoji: String = ""
    var id = UUID()
    var selectedEmojiIndex: IndexPath?
    var selectedColor: IndexPath?
    
    init(isNew: Bool,isHabitOrRegular: Bool) {
        self.isNew = isNew
        self.isHabitOrRegular = isHabitOrRegular
        self.parameters = GeometricParameters(cellCount: 3, leftInsets: 16, rightInsets: 16, cellSpacing: 1)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        inputNameCategory.delegate = self
        setupNavigationBar(title: isHabitOrRegular ? NSLocalizedString("newRegularTrackerTitle", comment: "New habit") : NSLocalizedString("newIrregularTrackerTitle", comment: "New irregular tracker"))
        setupUI()
        if !isNew{
            setColor(trackerColor)
            setEmoji(trackerEmoji)
            inputNameCategory.text = trackerName
            countLabel.isHidden = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isNew{
            onReturnCategoryUpdate()
            updateTableCell()
        }
        
    }
    private func setColor(_ color: UIColor) {
        if let index = Constants.colors.firstIndex(where: { $0.isEqualTo(color) }) {
            let indexPath = IndexPath(item: index, section: 0)
            selectedColor = indexPath
        }
    }
    private func setEmoji(_ emoji: String) {
        if let index = Constants.emojis.firstIndex(of: emoji) {
            let indexPath = IndexPath(item: index, section: 0)
            selectedEmojiIndex = indexPath
        }
    }
    
}

extension CreateHabbitViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension CreateHabbitViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return parameters.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}
extension CreateHabbitViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return Constants.emojis.count
        }
        else{
            return Constants.colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            if indexPath == selectedEmojiIndex {
                cell.backgroundColor = .ypLightGray
                cell.layer.cornerRadius = 16
            } else {
                cell.backgroundColor = .clear
            }
            
            let emojiLabel = UILabel()
            emojiLabel.text = Constants.emojis[indexPath.item]
            emojiLabel.font = UIFont.systemFont(ofSize: 32)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(emojiLabel)
            
            NSLayoutConstraint.activate([
                emojiLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                emojiLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.colorIdentifier, for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            let color = Constants.colors[indexPath.item]
            cell.configure(with: color)
            
            if indexPath == selectedColor {
                cell.selectCell()
            } else {
                cell.deselectCell()
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let previousIndex = selectedEmojiIndex
            selectedEmojiIndex = indexPath
            
            if let previousIndex = previousIndex {
                collectionView.reloadItems(at: [previousIndex, indexPath])
            } else {
                collectionView.reloadItems(at: [indexPath])
            }
        }
        else{
            let previousIndex = selectedColor
            selectedColor = indexPath
            
            if let previousIndex = previousIndex {
                collectionView.reloadItems(at: [previousIndex, indexPath])
            } else {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        if collectionView == emojiCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CreateHabitCVHeader.headerIdentifier, for: indexPath) as? CreateHabitCVHeader else {
                fatalError("Failed to dequeue Trackers Header")
            }
            
            header.titleLabel.text = NSLocalizedString("emojiGroupTitle", comment: "Emoji collection")
            header.titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
            header.titleLabel.backgroundColor = .white
            return header
        } else if collectionView == colorCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CreateHabitCVHeader.headerIdentifier, for: indexPath) as? CreateHabitCVHeader else{
                fatalError("Failed to dequeue Header")
            }
            header.titleLabel.text = NSLocalizedString("colorGroupTitle", comment: "Color collection")
            header.titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
            header.titleLabel.backgroundColor = .white
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}
extension CreateHabbitViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isHabitOrRegular ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0: cell.titleLabel.text = NSLocalizedString("categoryTitle", comment: "Category group")
        case 1: cell.titleLabel.text = NSLocalizedString("scheduleTitle", comment: "Shedule group")
        default: break
        }
        
        cell.backgroundColor = .ypShedule
        cell.applySeparator(in: tableView, with: indexPath)
        return cell
    }
    
    private func onReturnCategory(_ category: String){
        self.category = category
        if let scheduleCell = self.sheduleTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CustomTableViewCell {
            scheduleCell.subtitleLabel.text = self.category
            scheduleCell.subtitleLabel.textColor = .gray
        }
        sheduleTableView.reloadData()
    }
    private func onReturnCategoryUpdate(){
        if let scheduleCell = self.sheduleTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CustomTableViewCell {
            scheduleCell.subtitleLabel.text = self.category
            scheduleCell.subtitleLabel.textColor = .gray
        }
        sheduleTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleVC = SheduleViewController()
            scheduleVC.delegate = self
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
        else {
                let viewController = CategoryViewContoller(selectedCategory: self.category) { [weak self] selectedCategory in
                    self?.onReturnCategory(selectedCategory)
                }
            navigationController?.pushViewController(viewController, animated: true)
            }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CreateHabbitViewController {
    func updateTableCell(){
        let dayNames = selectedWeekDays.map { $0.shortText }
        let selectedDays = Set(selectedWeekDays)
        var displayText: String?
        
        if selectedDays == Constants.allDays {
            displayText = NSLocalizedString("scheduleEveryDayOption", comment: "Every day")
        } else if selectedDays == Constants.weekDays {
            displayText = NSLocalizedString("sheduleWeekDays", comment: "Weekdays")
        } else if selectedDays == Constants.weekend {
            displayText = NSLocalizedString("sheduleWeekend", comment: "Weekend")
        } else {
            displayText = dayNames.joined(separator: ", ")
        }
        
        if let scheduleCell = sheduleTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CustomTableViewCell {
            scheduleCell.subtitleLabel.text = displayText
            scheduleCell.subtitleLabel.textColor = .gray
        }
        
        sheduleTableView.reloadData()
    }
    
    @objc func showWarning(_ textField: UITextField){
        if let text = textField.text, text.count > 38 {
            warningLabel.isHidden = false
        }
        else{
            warningLabel.isHidden = true
        }
    }
    
    func setupUI() {
    
        inputNameCategory.placeholder = NSLocalizedString("newCategoryPlaceholder", comment: "Put tracker title")
        inputNameCategory.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        inputNameCategory.backgroundColor = .ypShedule
        inputNameCategory.layer.cornerRadius = 16
        inputNameCategory.layer.masksToBounds = true
        inputNameCategory.rightViewMode = .always
        inputNameCategory.addTarget(self, action: #selector(showWarning(_:)), for: .editingChanged)
        inputNameCategory.clearButtonMode = .whileEditing
        let leftIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: inputNameCategory.frame.height))
        inputNameCategory.leftView = leftIndent
        inputNameCategory.leftViewMode = .always
        
        sheduleTableView.dataSource = self
        sheduleTableView.delegate = self
        sheduleTableView.backgroundColor = .white
        sheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        sheduleTableView.isScrollEnabled = false
        
        let stackView = UIStackView(arrangedSubviews: [inputNameCategory, warningLabel, sheduleTableView])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        inputNameCategory.heightAnchor.constraint(equalToConstant: 75).isActive = true
        sheduleTableView.heightAnchor.constraint(equalToConstant: CGFloat(isHabitOrRegular ? (2 * 75) : (1 * 75))).isActive = true
        
        let stackViewButtons = UIStackView()
        stackViewButtons.axis = .horizontal
        stackViewButtons.spacing = 8
        stackViewButtons.distribution = .fillEqually
        stackViewButtons.backgroundColor = .white
        stackViewButtons.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonCreate = createButtonCreate(title: isNew ? NSLocalizedString("createButtonTitle", comment: "Create tracker") :  NSLocalizedString("saveButtonTitle", comment: "Save update tracker"), action: #selector(createButtonTapped))
        let buttonReject = createButtonReject(title: NSLocalizedString("cancelButtonTitle", comment: "Delete tracker"), action: #selector(rejectButtonTapped))
        buttonCreate.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        buttonReject.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
        stackViewButtons.addArrangedSubview(buttonReject)
        stackViewButtons.addArrangedSubview(buttonCreate)
        
        let emojiLayout = UICollectionViewFlowLayout()
        emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollectionView.register(CreateHabitCVHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CreateHabitCVHeader.headerIdentifier)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.backgroundColor = .clear
        
        let colorLayout = UICollectionViewFlowLayout()
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorLayout)
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.colorIdentifier)
        colorCollectionView.register(CreateHabitCVHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CreateHabitCVHeader.headerIdentifier)
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.backgroundColor = .clear
        
        emojiLayout.sectionHeadersPinToVisibleBounds = true
        colorLayout.sectionHeadersPinToVisibleBounds = true
        emojiCollectionView.allowsMultipleSelection = false
        colorCollectionView.allowsMultipleSelection = false
        emojiCollectionView.isScrollEnabled = false
        colorCollectionView.isScrollEnabled = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackViewCollections = UIStackView(arrangedSubviews: [emojiCollectionView, colorCollectionView])
        stackViewCollections.spacing = 16
        stackViewCollections.axis = .vertical
        stackViewCollections.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.addSubview(countLabel)
        contentView.addSubview(stackView)
        contentView.addSubview(stackViewCollections)
        
      
        view.addSubview(scrollView)
        view.addSubview(stackViewButtons)
        
        NSLayoutConstraint.activate([
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 230),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 230),
            countLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: stackViewCollections.topAnchor, constant: -20),
            stackViewCollections.bottomAnchor.constraint(equalTo: stackViewButtons.topAnchor, constant: -20),
            
           
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, constant: 1),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
          
            stackViewCollections.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            stackViewCollections.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackViewCollections.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackViewButtons.topAnchor.constraint(equalTo: stackViewCollections.bottomAnchor, constant: 16),
            stackViewButtons.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackViewButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackViewButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func createButtonCreate(title: String, action: Selector) -> UIButton {
        let button = CustomButton(type: .create, title: title)
        return button
    }
    
    func createButtonReject(title: String, action: Selector) -> UIButton {
        let button = CustomButton(type: .reject, title: title)
        return button
    }
    
    @objc private func createButtonTapped() {
        guard let name = inputNameCategory.text, !name.isEmpty else { return }
        if let selectedColor = selectedColor, let selectedEmojiIndex = selectedEmojiIndex {
            let color = Constants.colors[selectedColor.item]
            let emoji = Constants.emojis[selectedEmojiIndex.item]
            
            if !isNew {
                if isHabitOrRegular {
                    createHabbitDelegate?.didUpdateHabbit(
                        id: self.id,
                        name: name,
                        days: selectedWeekDays,
                        color: color,
                        emoji: emoji,
                        category: self.category
                    )
                } else {
                    let allDays: [WeekDay] = []
                    createHabbitDelegate?.didUpdateIrregularEvent(
                        id: self.id,
                        name: name,
                        days: allDays,
                        color: color,
                        emoji: emoji,
                        category: self.category
                    )
                }
            } else {
                if isHabitOrRegular {
                    createHabbitDelegate?.didCreateHabbit(
                        name: name,
                        days: selectedWeekDays,
                        color: color,
                        emoji: emoji,
                        category: self.category
                    )
                } else {
                    let allDays: [WeekDay] = []
                    createHabbitDelegate?.didCreateIrregularEvent(
                        name: name,
                        days: allDays,
                        color: color,
                        emoji: emoji,
                        category: self.category
                    )
                }
            }
        } else {
            print("Ошибка: selectedColor или selectedEmojiIndex равен nil")
        }
        
        dismiss(animated: true)
    }

    
    @objc private func rejectButtonTapped(){
        print("createButtonTapped called") 
        navigationController?.popViewController(animated: true)
    }
}

extension CreateHabbitViewController: SheduleDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedWeekDays = days
        updateTableCell()
    }
}
