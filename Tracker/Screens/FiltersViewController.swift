//
//  Filters.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/06/2024.
//

import UIKit

final class FiltersViewController: UIViewController {
    // MARK: - Properties
    
    var onSelectFilter: ((TrackerFilter) -> Void)?
    var selectedFilter: TrackerFilter = .all
    private var previouslySelectedIndex: IndexPath?
    private let filterOptions = [L10n.allTrackersTitle, L10n.trackersForTodayTitle, L10n.completedTrackersTitle, L10n.uncompletedTrackersTitle]
    private let filterTypes: [TrackerFilter] = [.all, .today, .completed, .uncompleted]
    
    // MARK: - UI Components
    
    private var tableView: UITableView!
    private lazy var titleLabel = CustomTitleLabel(text: L10n.filters)
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        
        setupTitleLabel()
        setupTableView()
    }
    
    // MARK: - Setup Methods
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.configureStandardStyle()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        if let index = filterTypes.firstIndex(of: selectedFilter) {
            previouslySelectedIndex = IndexPath(row: index, section: 0)
        }
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConfigurableTableViewCell.identifier, for: indexPath) as? ConfigurableTableViewCell else {
            assertionFailure("Unable to dequeue DayTableViewCell")
            return UITableViewCell()
        }
        
        let isSelected = selectedFilter == filterTypes[indexPath.row]
        
        cell.configure(with: filterOptions[indexPath.row], accessoryType: .none)
        cell.accessoryType = isSelected ? .checkmark : .none
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        if isLastCell {
            cell.hideSeparator()
        } else {
            cell.showSeparator()
        }
        
        cell.layer.cornerRadius = isLastCell ? 16 : 0
        cell.layer.maskedCorners = isLastCell ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] : []
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = filterTypes[indexPath.row]
        
        if let previousIndex = previouslySelectedIndex {
            tableView.reloadRows(at: [previousIndex], with: .none)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        previouslySelectedIndex = indexPath
        
        onSelectFilter?(selectedFilter)
        dismiss(animated: true, completion: nil)
    }
}
