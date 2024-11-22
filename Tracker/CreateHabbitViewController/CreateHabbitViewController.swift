//
//  SheduleViewController.swift
//  Tracker
//
//  Created by Богдан Топорин on 31.10.2024.
//

import Foundation

import UIKit

protocol CreateHabbitDelegate: AnyObject {
    func didCreateHabbit(name: String, days: [WeekDay], color: UIColor, emoji: String)
    func didCreateIrregularEvent(name: String,days: [WeekDay], color: UIColor,emoji:String)
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
    
    let inputNameCategory = UITextField()
    weak var delegate: TrackerTypeDelegate?
    weak var createHabbitDelegate: CreateHabbitDelegate?
    private var parameters: GeometricParameters
    private var selectedEmojiIndex: IndexPath?
    private var selectedColor: IndexPath?
    private lazy var warningLabel: UILabel =  {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 17 ,weight: .regular)
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    private var emojiCollectionView: UICollectionView!
    private var colorCollectionView: UICollectionView!
    
    
    private var selectedWeekDays: [WeekDay] = []
    
    var isHabitOrRegular = false
    
    init() {
        self.parameters = GeometricParameters(cellCount: 6, leftInsets: 16, rightInsets: 16, cellSpacing: 6)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        inputNameCategory.delegate = self
        setupUI()
        
        
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
        let availableWidth = collectionView.bounds.width - 16 * 2 - parameters.cellSpacing * 5
        let widthPerItem = availableWidth / parameters.cellSpacing
        return CGSize(width: widthPerItem, height: 40)
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
            cell.backgroundColor = color
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            if indexPath == selectedColor {
                cell.layer.borderWidth = 4
                cell.layer.borderColor = UIColor.ypLightGray.cgColor
            }
            else {
                cell.layer.borderWidth = 0
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
            
            header.titleLabel.text = "Emoji"
            header.titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
            header.titleLabel.backgroundColor = .white
            return header
        } else if collectionView == colorCollectionView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CreateHabitCVHeader.headerIdentifier, for: indexPath) as! CreateHabitCVHeader
            header.titleLabel.text = "Цвет"
            header.titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
            header.titleLabel.backgroundColor = .white
            
            return header
        }
        
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50) // Укажите нужную высоту для заголовка
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
        case 0: cell.titleLabel.text = "Категория"
        case 1: cell.titleLabel.text = "Расписание"
        default: break
        }
        
        cell.backgroundColor = .ypShedule
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleVC = SheduleViewController()
            scheduleVC.modalPresentationStyle = .pageSheet
            scheduleVC.delegate = self
            self.present(scheduleVC, animated: true, completion: nil)
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
            displayText = "Каждый день"
        } else if selectedDays == Constants.weekDays {
            displayText = "Будние дни"
        } else if selectedDays == Constants.weekend {
            displayText = "Выходные"
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
        let title = UILabel()
        title.text = isHabitOrRegular ? "Новая привычка" : "Новое неругулярное событие"
        title.textColor = .black
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        inputNameCategory.placeholder = "Введите название трекера"
        inputNameCategory.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        inputNameCategory.backgroundColor = .ypShedule
        inputNameCategory.layer.cornerRadius = 16
        inputNameCategory.layer.masksToBounds = true
        inputNameCategory.rightViewMode = .always
        inputNameCategory.addTarget(self, action: #selector(showWarning(_:)), for: .editingChanged)
        let leftIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: inputNameCategory.frame.height))
        inputNameCategory.leftView = leftIndent
        inputNameCategory.leftViewMode = .always
        
        let rightIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: inputNameCategory.frame.height))
        inputNameCategory.rightView = rightIndent
        inputNameCategory.rightViewMode = .always
        
        sheduleTableView.dataSource = self
        sheduleTableView.delegate = self
        sheduleTableView.separatorStyle = isHabitOrRegular ? .singleLine : .none
        sheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        sheduleTableView.isScrollEnabled = false
        sheduleTableView.separatorStyle = isHabitOrRegular ? .singleLine : .none
        let stackView = UIStackView(arrangedSubviews: [inputNameCategory,warningLabel, sheduleTableView])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(title)
        view.addSubview(stackView)
        
        inputNameCategory.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        sheduleTableView.heightAnchor.constraint(equalToConstant: CGFloat(isHabitOrRegular ? (2*75) : (1*75))).isActive = true
        
        let stackViewButtons = UIStackView()
        stackViewButtons.axis = .horizontal
        stackViewButtons.spacing = 8
        stackViewButtons.distribution = .fillEqually
        stackViewButtons.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonCreate = createButtonCreate(title: "Cоздать", action: #selector(createButtonTapped))
        let buttonReject = createButtonReject(title: "Отменить", action: #selector(rejectButtonTapped))
        
        stackViewButtons.addArrangedSubview(buttonReject)
        stackViewButtons.addArrangedSubview(buttonCreate)
        
        view.addSubview(stackViewButtons)
        
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.scrollDirection = .vertical
        emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollectionView.register(CreateHabitCVHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CreateHabitCVHeader.headerIdentifier)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.backgroundColor = .clear
        
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.scrollDirection = .vertical
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
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        let stackViewCollections = UIStackView(arrangedSubviews: [emojiCollectionView,colorCollectionView])
        stackViewCollections.spacing = 16
        stackViewCollections.axis = .vertical
        stackViewCollections.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackViewCollections)
        NSLayoutConstraint.activate([
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 150),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 150),
        ])
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: title.bottomAnchor,constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackViewCollections.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            stackViewCollections.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackViewCollections.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackViewCollections.bottomAnchor.constraint(equalTo: stackViewButtons.topAnchor, constant: -16),
            inputNameCategory.heightAnchor.constraint(equalToConstant: 75),
            sheduleTableView.heightAnchor.constraint(equalToConstant: CGFloat(isHabitOrRegular ? (2 * 75) : (1 * 75))),
            
            stackViewButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stackViewButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackViewButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    
    func createButtonCreate(title: String, action: Selector) -> UIButton {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        button.addTarget(self, action: #selector(buttonPressedCreate(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleasedCreate(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return button
    }
    
    func createButtonReject(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitleColor(.red, for: .normal)
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return button
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.backgroundColor = .red
        sender.setTitleColor(.white, for: .normal)
    }
    
    @objc private func buttonReleased(_ sender: UIButton) {
        sender.backgroundColor = .white
        sender.setTitleColor(.red, for: .normal)
    }
    
    @objc private func buttonPressedCreate(_ sender: UIButton) {
        sender.backgroundColor = .darkGray
        
    }
    
    @objc private func buttonReleasedCreate(_ sender: UIButton) {
        sender.backgroundColor = .gray
    }
    
    @objc private func createButtonTapped() {
        guard let name = inputNameCategory.text, !name.isEmpty else { return }
        
        let color = Constants.colors[selectedColor!.item]
        let emoji = Constants.emojis[selectedEmojiIndex!.item]
        if isHabitOrRegular {
            createHabbitDelegate?.didCreateHabbit(
                name: name,
                days: selectedWeekDays,
                color: color,
                emoji: emoji
            )
        } else {
            let allDays: [WeekDay] = [.monday,.thursday,.friday,.saturday,.sunday,.tuesday,.wednesday]
            createHabbitDelegate?.didCreateIrregularEvent(
                name: name,
                days: allDays,
                color: color,
                emoji: emoji
            )
        }
        dismiss(animated: true)
    }
    
    @objc private func rejectButtonTapped(){
        dismiss(animated: true)
    }
}

extension CreateHabbitViewController: SheduleDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedWeekDays = days
        print(selectedWeekDays)
        updateTableCell()
    }
}
