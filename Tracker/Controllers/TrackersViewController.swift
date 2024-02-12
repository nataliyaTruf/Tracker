//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 15/01/2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var trackersCollectionView: UICollectionView!
    private var categories: [TrackerCategory] = [TrackerCategory(title: "По умолчанию", trackers: [])]
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIds = Set<UUID>()
    private var currentDate: Date = Date()
    private var isSearching = false
    private var params: GeometricParams
    
    // MARK: - UI Components
    
    private lazy var emptyStateImageView = {
        let image = UIImageView(image: UIImage(named: "error1"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    init() {
        self.params = GeometricParams(cellCount: 2, leftInsets: 16, rightInsets: 16, cellSpacing: 9)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setupEmptyStateTrackers()
        setupTrackersCollectionView()
        setupNavigationBar()
        setupSearchController()
        categories = MockDataService.shared.getDummyTrackers()
        filterTrackersForSelectedDate()
    }
    
    // MARK: - Navigation
    
    @objc private func addTrackerButtonTapped() {
        let selectTrackerVC = SelectTrackerViewController()
        selectTrackerVC.delegate = self
        selectTrackerVC.modalPresentationStyle = .pageSheet
        selectTrackerVC.onTrackerCreated = { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
        present(selectTrackerVC, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        currentDate = datePicker.date
        filterTrackersForSelectedDate()
        trackersCollectionView.reloadData()
    }
    
    // MARK: - Setup Methods
    
    private func setupEmptyStateTrackers() {
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -330),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: +8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        emptyStateLabel.isHidden = true
        emptyStateImageView.isHidden = true
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        title = "Трекеры"
        
        let addButton = UIButton(type: .custom)
        if let iconImage = UIImage(named: "add_tracker")?.withRenderingMode(.alwaysOriginal) {
            addButton.setImage(iconImage, for: .normal)
        }
        addButton.addTarget(
            self,
            action: #selector(addTrackerButtonTapped),
            for: .touchUpInside
        )
        
        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        let addButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = addButtonItem
        
        setupDatePickerItem()
    }
    
    private func setupDatePickerItem() {
        let datePicker = UIDatePicker()
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(
            self,
            action: #selector(dateChanged(_ :)),
            for: .valueChanged
        )
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
    }
    
    private func setupTrackersCollectionView() {
        let layout = UICollectionViewFlowLayout()
        trackersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        trackersCollectionView.register(TrackersCell.self, forCellWithReuseIdentifier: TrackersCell.cellIdetnifier)
        trackersCollectionView.register(TrackersHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersHeader.headerIdentifier)
        
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersCollectionView)
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - UI Updates
    
    private func updateView() {
        let hasTrackersToShow = !filteredCategories.flatMap { $0.trackers }.isEmpty
        
        trackersCollectionView.isHidden = !hasTrackersToShow
        emptyStateLabel.isHidden = hasTrackersToShow
        emptyStateImageView.isHidden = hasTrackersToShow
        
        if !hasTrackersToShow {
            if isSearching {
                emptyStateLabel.text = "Ничего не найдено"
                emptyStateImageView.image = UIImage(named: "error2")
            } else {
                emptyStateLabel.text = "Что будем отслеживать?"
                emptyStateImageView.image = UIImage(named: "error1")
            }
        }
    }
}

// MARK: - UISearchControllerDelegate, UISearchBarDelegate

extension TrackersViewController: UISearchControllerDelegate, UISearchBarDelegate {
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String ) {
        isSearching = !searchText.isEmpty
        
        if searchText.isEmpty {
            filteredCategories = categories
        } else {
            filteredCategories = categories.map { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    return tracker.name.localizedCaseInsensitiveContains(searchText)
                }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }
        trackersCollectionView.reloadData()
        updateView()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        isSearching = false
        updateView()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(withReuseIdentifier: TrackersCell.cellIdetnifier, for: indexPath) as? TrackersCell else { fatalError("Unable to dequeue TrackersCell") }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        cell.isCompleted = completedTrackerIds.contains(tracker.id) && isTrackerCompletedOnCurrentDate(trackerId: tracker.id)
        let daysCount = countCompletedDays(for: tracker.id)
        cell.configure(with: tracker, completedDays: daysCount)
        
        cell.onToggleCompleted = { [weak self] in
            guard let self = self, self.currentDate <= Date() else { return }
            cell.isCompleted.toggle()
            self.toggleTrackerCompleted(trackerId: tracker.id, at: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            guard let header = trackersCollectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackersHeader.headerIdentifier,
                for: indexPath
            ) as? TrackersHeader else { fatalError("Failed to cast UICollectionReusableView to TrackersHeader") }
            
            header.titleLabel.text = categories[indexPath.section].title
            return header
            
        default:
            fatalError("Unexpected element kind")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let avaliableWidth = trackersCollectionView.bounds.width - params.paddingWidth
        let widthPerItem = avaliableWidth / CGFloat(params.cellCount)
        let heightPerItem = widthPerItem * (148 / 167)
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: params.leftInsets, bottom: 16, right: params.rightInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let header = TrackersHeader()
        
        header.titleLabel.text = categories[section].title
        let size = header.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return size
    }
}

// MARK: - Tracker Management

extension TrackersViewController {
    private func toggleTrackerCompleted(trackerId: UUID, at indexPath: IndexPath) {
        if isTrackerCompletedOnCurrentDate(trackerId: trackerId) {
            completedTrackerIds.remove(trackerId)
            completedTrackers.removeAll {$0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate)}
        } else {
            completedTrackerIds.insert(trackerId)
            let newRecord = TrackerRecord(id: trackerId, date: currentDate)
            completedTrackers.append(newRecord)
        }
        UIView.performWithoutAnimation {
            trackersCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func isTrackerCompletedOnCurrentDate(trackerId: UUID) -> Bool {
        return completedTrackers.contains(where: { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate)})
    }
    
    private func countCompletedDays(for trackerId: UUID) -> Int {
        let completedDates = completedTrackers.filter { $0.id == trackerId }.map { $0.date }
        let uniqueDates = Set(completedDates)
        return uniqueDates.count
    }
    
    private func filterTrackersForSelectedDate() {
        let dayOfWeek = currentDate.toWeekday()
        filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                guard let schedule = tracker.scedule else { return true }
                return schedule.isReccuringOn(dayOfWeek)
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        updateView()
    }
}

// MARK: - TrackerCreationDelegate

extension TrackersViewController: TrackerCreationDelegate {
    func trackerCreated(_ tracker: Tracker) {
        var newTrackers = categories[0].trackers
        newTrackers.append(tracker)
        
        let updateCategory = TrackerCategory(title: categories[0].title, trackers: newTrackers)
        
        categories[0] = updateCategory
        
        filterTrackersForSelectedDate()
        trackersCollectionView.reloadData()
    }
}
