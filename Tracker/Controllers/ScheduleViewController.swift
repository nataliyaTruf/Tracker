//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/02/2024.
//

import UIKit


final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    
    var onScheduleUpdated: ((ReccuringSchedule) -> Void)?
    var schedule = ReccuringSchedule(mondays: false, tuesdays: false, wednesdays: false, thursdays: false, fridays: false, saturdays: false, sundays: false)
    let days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    var tableView: UITableView!
    
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textColor = UIColor(resource: .ypBlackDay)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor(resource: .ypWhiteDay), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlackDay)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setupDoneButton()
        setupTableView()
        setuptitleLabel()
    }
    
    // MARK: - Actions
    
    @objc func doneButtonTapped() {
        onScheduleUpdated?(schedule)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup Methods
    
    private func setupDoneButton() {
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DayTableViewCell.self, forCellReuseIdentifier: DayTableViewCell.dayCellIdentifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -47),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setuptitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
        ])
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DayTableViewCell.dayCellIdentifier, for: indexPath) as? DayTableViewCell else {
            fatalError("Unable to dequeue DayTableViewCell")
        }
        
        cell.selectionStyle = .none
        
        let isOn: Bool = {
            switch indexPath.row {
            case 0: return schedule.mondays
            case 1: return schedule.tuesdays
            case 2: return schedule.wednesdays
            case 3: return schedule.thursdays
            case 4: return schedule.fridays
            case 5: return schedule.saturdays
            case 6: return schedule.sundays
            default: return false
            }
        }()
        
        cell.configure(with: days[indexPath.row], isOn: isOn
        )
        
        cell.onSwitchValueChanged = { [weak self] isOn in
            self?.updateSchedule(forDay: indexPath.row, isOn: isOn)
        }
        
        if indexPath.row == days.count - 1 {
            cell.hideSeparator()
        } else {
            cell.showSeparator()
        }
        
        if indexPath.row == days.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - Schedule Management

extension ScheduleViewController {
    func updateSchedule(forDay dayIndex: Int, isOn: Bool) {
        switch dayIndex {
        case 0:
            schedule.mondays = isOn
        case 1:
            schedule.tuesdays = isOn
        case 2:
            schedule.wednesdays = isOn
        case 3:
            schedule.thursdays = isOn
        case 4:
            schedule.fridays = isOn
        case 5:
            schedule.saturdays = isOn
        case 6:
            schedule.sundays = isOn
        default:
            break
        }
        tableView.reloadRows(at: [IndexPath(row: dayIndex, section: 0)], with: .none)
        // TODO: Implement data persistence for schedule changes
    }
}
