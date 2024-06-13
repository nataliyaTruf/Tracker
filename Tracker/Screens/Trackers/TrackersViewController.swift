//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 15/01/2024.
//

import UIKit
import Combine

/**
 По заданию CategoryListViewController переписан на архитектуру MVVM с байндингами через замыкания, но после согласования с наставником, я решила использовать Combine для других контроллеров, чтобы попробовать разные подходы к реализации паттерна MVVM.
 Таким образом, пришлось пожертвовать однородностью стиля кода ради учебных целей.
 
 As per the assignment, CategoryListViewController was refactored to the MVVM architecture with bindings via closures. However, after consulting with my mentor, I decided to use Combine for other controllers to experiment with different approaches to implementing the MVVM pattern.
 Thus, I had to sacrifice code style uniformity for educational purposes.
 */

final class TrackersViewController: UIViewController {
    // MARK: - Properties
    
    var viewModel = TrackersViewModel()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var trackersCollectionView: UICollectionView!
    private var filterButton: UIButton!
    private var params: GeometricParams
    private var trackerCreationDates: [UUID : Date] = [:]
    private var selectedFilter: TrackerFilter = .all
    private var cancelables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    init() {
        self.params = GeometricParams(cellCount: 2, leftInsets: 0, rightInsets: 0, cellSpacing: 9)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataStack.shared.trackerStore.delegate = self
        CoreDataStack.shared.trackerRecordStore.delegate = self
        CoreDataStack.shared.trackerCategoryStore.delegate = self
        view.backgroundColor = .ypWhiteDay
        setupEmptyStateTrackers()
        setupTrackersCollectionView()
        setupNavigationBar()
        setupSearchController()
        setupFilterButton()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.logEvent(event: "open", screen: "Main")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.logEvent(event: "close", screen: "Main")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            trackersCollectionView.backgroundColor = .ypWhiteDay
            setupDatePickerItem()
            setupNavigationBar()
            if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                updateSearchTextFieldAppearance(searchTextField)
            }
        }
    }
    
    // MARK: - Binding ViewModel
    
    private func bindViewModel() {
        viewModel.$filteredCategories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.trackersCollectionView.reloadData()
                self?.updateFilterButtonVisibility()
            }
            .store(in: &cancelables)
        
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleViewState(state)
                self?.updateFilterButtonVisibility()
            }
            .store(in: &cancelables)
        
        viewModel.$currentDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.filterTrackersForSelectedDate()
                self?.updateFilterButtonVisibility()
            }
            .store(in: &cancelables)
        
        viewModel.$selectedFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filter in
                self?.applyFilter(filter)
                self?.updateFilterButtonVisibility()
            }
            .store(in: &cancelables)
    }
    
    // MARK: - Setup Methods
    
    private func setupEmptyStateTrackers() {
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 49)
        ])
        
        emptyStateView.isHidden = true
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = L10n.trackers
        let addButton = UIButton(type: .custom)
        var iconImage: UIImage?
        
        if traitCollection.userInterfaceStyle == .dark {
            iconImage = UIImage(named: "add_tracker_dark")?.withRenderingMode(.alwaysOriginal)
        } else {
            iconImage = UIImage(named: "add_tracker")?.withRenderingMode(.alwaysOriginal)
        }
        
        if let iconImage = iconImage {
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
        datePicker.widthAnchor.constraint(equalToConstant: 110).isActive = true
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        
        if traitCollection.userInterfaceStyle == .dark {
            datePicker.overrideUserInterfaceStyle = .light
            datePicker.backgroundColor = UIColor.ypLightGray
            datePicker.layer.cornerRadius = 8
            datePicker.layer.masksToBounds = true
            
            let textFieldInsideDatePicker = (datePicker.subviews[0].subviews[0].subviews[0] as? UITextField)
            textFieldInsideDatePicker?.textColor = UIColor.black
        } else {
            datePicker.overrideUserInterfaceStyle = .unspecified
            datePicker.backgroundColor = nil
            datePicker.layer.cornerRadius = 0
        }
        
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
        trackersCollectionView.register(ReusableHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ReusableHeader.identifier)
        
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersCollectionView)
        trackersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        trackersCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        trackersCollectionView.backgroundColor = .ypWhiteDay
    }
    
    private func setupFilterButton() {
        filterButton = UIButton(type: .system)
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = .ypBlue
        filterButton.setTitleColor(.ypWhiteDay, for: .normal)
        filterButton.layer.cornerRadius = 16
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        updateFilterButtonVisibility()
    }
    
    // MARK: - UI Updates
    
    private func handleViewState(_ state: ViewState) {
        switch state {
        case .empty:
            trackersCollectionView.isHidden = true
            emptyStateView.isHidden = false
            emptyStateView.configure(with: viewModel.isSearching ? .noResults : .noTrackers, labelHeight: 18)
        case .populated:
            trackersCollectionView.isHidden = false
            emptyStateView.isHidden = true
        }
    }
    
    private func toggleTrackerCompleted(trackerId: UUID, at indexPath: IndexPath) {
        AnalyticsService.logEvent(event: "click", screen: "Main", item: "track")
        viewModel.toggleTrackerCompleted(trackerId: trackerId)
        UIView.performWithoutAnimation { [weak self] in
            self?.trackersCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    func togglePinTracker(tracker: Tracker, at indexPath: IndexPath) {
        if viewModel.isTrackerPinned(tracker) {
            viewModel.unpinTracker(tracker)
        } else {
            viewModel.pinTracker(tracker)
        }
        trackersCollectionView.reloadData()
    }

    private func updateFilterButtonVisibility() {
        let hasTrackersForSelectedDate = viewModel.categories.flatMap { $0.trackers }.contains { tracker in
            let dayOfWeek = viewModel.currentDate.toWeekday()
            if let schedule = tracker.schedule {
                return schedule.isReccuringOn(dayOfWeek)
            } else {
                if let creationDate = viewModel.trackerCreationDates[tracker.id] {
                    return Calendar.current.isDate(viewModel.currentDate, inSameDayAs: creationDate)
                }
                return false
            }
        }

        let noResults = viewModel.filteredCategories.isEmpty && viewModel.isSearching

        if noResults && hasTrackersForSelectedDate {
            emptyStateView.isHidden = false
            emptyStateView.configure(with: .noResults, labelHeight: 18)
            filterButton.isHidden = false
        } else if !hasTrackersForSelectedDate {
            emptyStateView.isHidden = false
            emptyStateView.configure(with: .noTrackers, labelHeight: 18)
            filterButton.isHidden = true
        } else {
            emptyStateView.configure(with: .noResults, labelHeight: 18)
            filterButton.isHidden = false
        }
    }

    private func updateFilterButtonAppearance() {
        if viewModel.selectedFilter == .all {
            filterButton.setTitleColor(.ypWhiteDay, for: .normal)
        } else {
            filterButton.setTitleColor(.ypRed, for: .normal)
        }
    }
    
    // MARK: - Helper Methods
    
    private func applyFilter(_ filter: TrackerFilter) {
        if filter == .today {
            viewModel.currentDate = Date()
        }
        viewModel.filterTrackersForSelectedDate()
        trackersCollectionView.reloadData()
        updateDatePickerIfNeeded(for: filter)
        updateFilterButtonAppearance()
    }
    
    private func updateDatePickerIfNeeded(for filter: TrackerFilter) {
        if filter == .today {
            if let datePickerItem = navigationItem.rightBarButtonItem?.customView as? UIDatePicker {
                datePickerItem.date = Date()
                updateFilterButtonAppearance()
            }
        }
    }
    
    // MARK: - Navigation
    
    private func presentEditTrackerViewController(tracker: Tracker) {
        let isHabit = tracker.schedule != nil
        let isPinned = viewModel.isTrackerPinned(tracker)
        let editTrackerVC = CreateTrackerViewController(isHabit: isHabit, isEditing: true, existingTrackerId: tracker.id, isPinned: isPinned)
        
        
        editTrackerVC.loadExistingTrackerData(tracker.id)
        editTrackerVC.onCompletion = { [weak self] in
            self?.viewModel.loadCategories()
            self?.trackersCollectionView.reloadData()
        }
        editTrackerVC.modalPresentationStyle = .pageSheet
        present(editTrackerVC, animated: true, completion: nil)
    }
    
    @objc private func addTrackerButtonTapped() {
        AnalyticsService.logEvent(event: "click", screen: "Main", item: "add_track")
        let selectTrackerVC = SelectTrackerViewController()
        selectTrackerVC.modalPresentationStyle = .pageSheet
        selectTrackerVC.onTrackerCreated = { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
        present(selectTrackerVC, animated: true, completion: nil)
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.logEvent(event: "click", screen: "Main", item: "filter")
        let filtersVC = FiltersViewController()
        filtersVC.selectedFilter = viewModel.selectedFilter
        filtersVC.modalPresentationStyle = .pageSheet
        filtersVC.onSelectFilter = { [weak self] filter in
            self?.viewModel.selectedFilter = filter
            self?.applyFilter(filter)
            self?.dismiss(animated: false, completion: nil)
        }
        present(filtersVC, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        viewModel.currentDate = datePicker.date
        viewModel.loadCompletedTrackers()
        viewModel.filterTrackersForSelectedDate()
    }
}

// MARK: - UISearchControllerDelegate, UISearchBarDelegate

extension TrackersViewController: UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate  {
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = L10n.search
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.delegate = self
            updateSearchTextFieldAppearance(searchTextField)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String ) {
        viewModel.isSearching = !searchText.isEmpty
        
        if searchText.isEmpty {
            viewModel.filterTrackersForSelectedDate()
        } else {
            viewModel.filteredCategories = viewModel.categories.map { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    return tracker.name.localizedCaseInsensitiveContains(searchText)
                }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }
        viewModel.updateViewState()
        trackersCollectionView.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.isSearching = false
        viewModel.filterTrackersForSelectedDate()
        viewModel.updateViewState()
        trackersCollectionView.reloadData()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.text?.isEmpty == true {
            viewModel.isSearching = false
            viewModel.filterTrackersForSelectedDate()
            viewModel.updateViewState()
            trackersCollectionView.reloadData()
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func updateSearchTextFieldAppearance(_ searchTextField: UITextField) {
        if traitCollection.userInterfaceStyle == .dark {
            searchTextField.textColor = UIColor.white
            searchTextField.attributedPlaceholder = NSAttributedString(string: L10n.search, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            
            if let leftView = searchTextField.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.white
            }
        } else {
            searchTextField.textColor = UIColor.black
            searchTextField.attributedPlaceholder = NSAttributedString(string: L10n.search, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            if let leftView = searchTextField.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.darkGray
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(withReuseIdentifier: TrackersCell.cellIdetnifier, for: indexPath) as? TrackersCell else {
            assertionFailure("Error: Unable to dequeue TrackersCell")
            return UICollectionViewCell()
        }
        
        let tracker = viewModel.filteredCategories[indexPath.section].trackers[indexPath.row]
        
        cell.isCompleted = viewModel.completedTrackerIds.contains(tracker.id) && viewModel.isTrackerCompletedOnCurrentDate(trackerId: tracker.id)
        let daysCount = viewModel.countCompletedDays(for: tracker.id)
        
        let isPinned = viewModel.isTrackerPinned(tracker)
        cell.configure(with: tracker, completedDays: daysCount, isPinned: isPinned)
        
        cell.onToggleCompleted = { [weak self] in
            guard let self = self, self.viewModel.currentDate <= Date() else { return }
            self.toggleTrackerCompleted(trackerId: tracker.id, at: indexPath)
        }
        
        cell.onPin = { [weak self] in
            self?.togglePinTracker(tracker: tracker, at: indexPath)
        }
        
        cell.onEdit = { [weak self] in
            self?.presentEditTrackerViewController(tracker: tracker)
        }
        
        cell.onDelete = { [weak self] in
            let alert = UIAlertController(
                title: "Уверены что хотите удалить трекер?",
                message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(
                title: "Удалить",
                style: .destructive
            ) { [weak self] _ in
                guard let self = self else { return }
                let tracker = self.viewModel.filteredCategories[indexPath.section].trackers[indexPath.row]
                self.viewModel.deleteTracker(trackerId: tracker.id)
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            guard let header = trackersCollectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ReusableHeader.identifier,
                for: indexPath
            ) as? ReusableHeader else {
                assertionFailure("Failed to cast UICollectionReusableView to TrackersHeader")
                return UICollectionReusableView()
            }
            
            let title = viewModel.filteredCategories[indexPath.section].title
            header.configure(with: title)
            
            return header
            
        default:
            assertionFailure("Unexpected element kind")
            return UICollectionReusableView()
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
        let header = ReusableHeader()
        
        header.titleLabel.text = viewModel.filteredCategories[section].title
        let size = header.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return size
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidChangeContent() {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.loadCategories()
            self?.trackersCollectionView.reloadData()
        }
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent(records: [TrackerRecord]) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.loadCompletedTrackers()
            self?.trackersCollectionView.reloadData()
        }
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChangeContent(_ store: TrackerCategoryStore) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.loadCategories()
            self?.trackersCollectionView.reloadData()
        }
    }
}
