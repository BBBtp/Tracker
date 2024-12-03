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
        setupNavigationBar(title: "Расписание")
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
        
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1

        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else if isLastRow {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.layer.cornerRadius = 0
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }

}

extension SheduleViewController {
    
    private func setupUI(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 47
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(7 * 75)).isActive = true
        
        let buttonCreate = createButton(title: "Готово", action: #selector(createButtonTapped))
        stackView.addArrangedSubview(buttonCreate)
    }
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = CustomButton(type: .create, title: title)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func createButtonTapped() {
        let selectedWeekDays = selectedDays.compactMap { WeekDay(rawValue: $0.key + 1) }
        delegate?.didSelectDays(selectedWeekDays)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        selectedDays[sender.tag] = sender.isOn
    }
}
