//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/02/2024.
//

import UIKit
import Combine

/**
 По заданию CategoryListViewController переписан на архитектуру MVVM с байндингами через замыкания, но после согласования с наставником, я решила использовать Combine для других контроллеров, чтобы попробовать разные подходы к реализации паттерна MVVM.
 Таким образом, пришлось пожертвовать однородностью стиля кода ради учебных целей.
 
 As per the assignment, CategoryListViewController was refactored to the MVVM architecture with bindings via closures. However, after consulting with my mentor, I decided to use Combine for other controllers to experiment with different approaches to implementing the MVVM pattern.
 Thus, I had to sacrifice code style uniformity for educational purposes.
 */

final class ScheduleViewController: UIViewController {
    // MARK: - Properties
    
    var viewModel: ScheduleViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private var tableView: UITableView!
    
    private lazy var titleLabel = CustomTitleLabel(text: "Расписание")
    
    private lazy var doneButton: CustomButton = {
        let button = CustomButton(title: "Готово")
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setupDoneButton()
        setupTableView()
        setuptitleLabel()
        bindViewModel()
    }
    
    // MARK: - Binding ViewModel
    
    private func bindViewModel() {
        viewModel.$selectedDays
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup Methods
    
    private func setupDoneButton() {
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.configureStandardStyle()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -47)
        ])
    }
    
    private func setuptitleLabel() {
        view.addSubview(titleLabel)
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        viewModel.onScheduleUpdated?(ReccuringSchedule(recurringDays: viewModel.selectedDays.map { $0.rawValue }))
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConfigurableTableViewCell.identifier, for: indexPath) as? ConfigurableTableViewCell else {
            assertionFailure("Unable to dequeue DayTableViewCell")
            return UITableViewCell()
        }
        
        let day = viewModel.days[indexPath.row]
        let isOn = viewModel.selectedDays.contains(day)
        
        cell.configure(with: day.localizedStringShort, additionalText: nil, accessoryType: .switchControl(isOn: isOn))
        
        cell.onSwitchValueChanged = { [weak self] isOn in
            self?.updateSchedule(forDay: indexPath.row, isOn: isOn)
        }
        
        if indexPath.row == viewModel.days.count - 1 {
            cell.hideSeparator()
        } else {
            cell.showSeparator()
        }
        
        if indexPath.row == viewModel.days.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
        }
        return cell
    }
}

// MARK: - Schedule Management

extension ScheduleViewController {
    private func updateSchedule(forDay dayIndex: Int, isOn: Bool) {
        let day = viewModel.days[dayIndex]
        
        if isOn {
            if !viewModel.selectedDays.contains(day) {
                viewModel.selectedDays.append(day)
                viewModel.selectedDays.sort(by: { $0.rawValue < $1.rawValue })
            }
        } else {
            viewModel.selectedDays.removeAll { $0 == day }
        }
        tableView.reloadRows(at: [IndexPath(row: dayIndex, section: 0)], with: .none)
    }
}
