//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 08.05.2026.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ weekDays: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private let weekDayValues: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private var schedule: [Bool] = [false, false, false, false, false, false, false]
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 16)
        return label
    }().forAutoLayout
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.identifier)
        tableView.rowHeight = 75
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        tableView.layer.cornerRadius = 16
        return tableView
    }().forAutoLayout
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.doneButtonTapped()
        })
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.whiteDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        return button
    }().forAutoLayout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setElements()
    }
    
    private func setElements() {
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 39),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
            //tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 16),
        ])
        
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    @objc private func doneButtonTapped() {
        var selectedWeekDays: [WeekDay] = []
        for (index, isSelected) in schedule.enumerated() {
            if isSelected {
                selectedWeekDays.append(weekDayValues[index])
            }
        }
        
        delegate?.didSelectSchedule(selectedWeekDays)
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleTableViewCell.identifier,
            for: indexPath
        ) as! ScheduleTableViewCell
        
        cell.configure(
            day: days[indexPath.row],
            isEnabled: schedule[indexPath.row],
            delegate: self
        )
        cell.tag = indexPath.row
        cell.backgroundColor = .backgroundDay
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - ScheduleTableViewCellDelegate
extension ScheduleViewController: ScheduleTableViewCellDelegate {
    func switchValueChanged(isOn: Bool, at index: Int) {
        schedule[index] = isOn
        print("День \(days[index]): \(isOn ? "включен" : "выключен")")
    }
}
