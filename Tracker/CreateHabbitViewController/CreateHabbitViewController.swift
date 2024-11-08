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
    
    let sheduleTableView = UITableView()
    let inputNameCategory = UITextField()
    weak var delegate: TrackerTypeDelegate?
    weak var createHabbitDelegate: CreateHabbitDelegate?
    private lazy var warningLabel: UILabel =  {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 17 ,weight: .regular)
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    private let colors: [UIColor] = [.ypColor1,
                                     .ypColor2,
                                     .ypColor3,
                                     .ypColor4,
                                     .ypColor5,
                                     .ypColor6,
                                     .ypColor7,
                                     .ypColor8,
                                     .ypColor9,
                                     .ypColor10,
                                     .ypColor11,
                                     .ypColor12,
                                     .ypColor13,
                                     .ypColor14,
                                     .ypColor15,
                                     .ypColor16,
                                     .ypColor17,
                                     .ypColor18,
                                  
                                     
    ]
    private var selectedWeekDays: [WeekDay] = []
    private let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    var isHabitOrRegular = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        inputNameCategory.delegate = self
        setupUI()
        
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
        
        if indexPath.row == 0 {
            cell.titleLabel.text = "Категория"
            
        } else if indexPath.row == 1 {
            cell.titleLabel.text = "Расписание"
            
        }
        
        cell.backgroundColor = .ypLightGray
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
        
        
        let allDays: Set<WeekDay> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        let weekDays: Set<WeekDay> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        let weekend: Set<WeekDay> = [.saturday, .sunday]
        
        let selectedDays = Set(selectedWeekDays)
        var displayText: String?
        
        
        if selectedDays == allDays {
            displayText = "Каждый день"
        } else if selectedDays == weekDays {
            displayText = "Будние дни"
        } else if selectedDays == weekend {
            displayText = "Выходные"
        } else {
            displayText = dayNames.joined(separator: ", ")
        }
        
        
        if let scheduleCell = sheduleTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CustomTableViewCell {
            scheduleCell.subtitleLabel.text = displayText
            scheduleCell.subtitleLabel.textColor = .gray // Убедимся, что текст виден
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
        title.translatesAutoresizingMaskIntoConstraints = false  // Add this line to enable Auto Layout
        
        inputNameCategory.placeholder = "Введите название трекера"
        inputNameCategory.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        inputNameCategory.backgroundColor = .ypLightGray
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
        sheduleTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "customCell")
        sheduleTableView.separatorStyle = .none
        sheduleTableView.rowHeight = 75
        sheduleTableView.estimatedRowHeight = 75
        sheduleTableView.layer.cornerRadius = 16
        sheduleTableView.showsVerticalScrollIndicator = false
        sheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        sheduleTableView.isScrollEnabled = false
        sheduleTableView.separatorStyle = isHabitOrRegular ? .singleLine : .none
        sheduleTableView.backgroundColor = .lightGray
        let stackView = UIStackView(arrangedSubviews: [inputNameCategory,warningLabel, sheduleTableView])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(title)
        view.addSubview(stackView)
       
        
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        inputNameCategory.heightAnchor.constraint(equalToConstant: 75).isActive = true
       
        sheduleTableView.heightAnchor.constraint(equalToConstant: CGFloat(isHabitOrRegular ? (2*75) : (1*75))).isActive = true
        
        // Create and configure stack view for buttons
        let stackViewButtons = UIStackView()
        stackViewButtons.axis = .horizontal
        stackViewButtons.spacing = 8
        stackViewButtons.distribution = .fillEqually
        stackViewButtons.translatesAutoresizingMaskIntoConstraints = false
        
        // Create buttons
        let buttonCreate = createButtonCreate(title: "Cоздать", action: #selector(createButtonTapped))
        let buttonReject = createButtonReject(title: "Отменить", action: #selector(rejectButtonTapped))
        
        // Add buttons to the button stack view
        stackViewButtons.addArrangedSubview(buttonReject)
        stackViewButtons.addArrangedSubview(buttonCreate)
        
        // Add button stack view to the main view
        view.addSubview(stackViewButtons)
        
        // Set constraints for stackViewButtons
        NSLayoutConstraint.activate([
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
            
            let randomColor = colors.randomElement() ?? .gray
            let randomEmoji = emojis.randomElement() ?? "🙂"
            
            if isHabitOrRegular {
                createHabbitDelegate?.didCreateHabbit(
                    name: name,
                    days: selectedWeekDays,
                    color: randomColor,
                    emoji: randomEmoji
                )
            } else {
                let allDays: [WeekDay] = []
                createHabbitDelegate?.didCreateIrregularEvent(
                    name: name,
                    days: allDays,
                    color: randomColor,
                    emoji: randomEmoji
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



class CustomTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}


