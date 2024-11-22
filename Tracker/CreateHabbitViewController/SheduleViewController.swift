//
//  CreateHabbitViewController.swift
//  Tracker
//
//  Created by Богдан Топорин on 31.10.2024.
//

import Foundation
import UIKit

final class SheduleViewController: UIViewController, UITableViewDelegate {
    weak var delegate: SheduleDelegate?
    var selectedDays = [Int:Bool]()
    var onDaysSelected: (([Int:Bool]) -> Void)?
    let tableView = UITableView()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
}


extension SheduleViewController: UITabBarDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
        
        let day = WeekDay(rawValue: indexPath.row + 1)?.fullText
        cell.textLabel?.text = day
        
        let daySwitch = UISwitch()
        daySwitch.onTintColor = .ypBlue
        daySwitch.tag = indexPath.row
        daySwitch.isOn = selectedDays[indexPath.row] ?? false
        daySwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = daySwitch
        cell.selectionStyle = .none
        cell.backgroundColor = .ypShedule
        return cell
    }
}

extension SheduleViewController {
    
    private func setupUI(){
        let title = UILabel()
        title.text = "Расписание"
        title.textColor = .black
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .ypShedule
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 47
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(title)
        view.addSubview(stackView)
        stackView.addArrangedSubview(tableView)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 39),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(7 * 75)).isActive = true
        
        let buttonCreate = createButton(title: "Готово", action: #selector(createButtonTapped))
        stackView.addArrangedSubview(buttonCreate)
    }
    private func createButton(title: String, action: Selector) -> UIButton {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
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
        sender.backgroundColor = .darkGray
    }
    
    @objc private func buttonReleased(_ sender: UIButton) {
        sender.backgroundColor = .black
    }
    
    @objc private func createButtonTapped() {
        let selectedWeekDays = selectedDays.compactMap { WeekDay(rawValue: $0.key + 1) }
        delegate?.didSelectDays(selectedWeekDays)
        dismiss(animated: true)
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        selectedDays[sender.tag] = sender.isOn
    }
}
