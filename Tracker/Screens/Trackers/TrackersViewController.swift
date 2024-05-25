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
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var trackersCollectionView: UICollectionView!
    private var params: GeometricParams
    private var trackerCreationDates: [UUID : Date] = [:]
    
    private var viewModel = TrackersViewModel()
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
        bindViewModel()
        viewModel.loadCategories()
        viewModel.loadCompletedTrackers()
    }
    
    // MARK: - Binding ViewModel
    
    private func bindViewModel() {
        viewModel.$filteredCategories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.trackersCollectionView.reloadData()
            }
            .store(in: &cancelables)
        
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleViewState(state)
            }
            .store(in: &cancelables)
        
        viewModel.$currentDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.trackersCollectionView.reloadData()
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
        datePicker.widthAnchor.constraint(equalToConstant: 110).isActive = true
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
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
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
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
        viewModel.toggleTrackerCompleted(trackerId: trackerId)
        UIView.performWithoutAnimation { [weak self] in
            self?.trackersCollectionView.reloadItems(at: [indexPath])
        }
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
    
    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        viewModel.currentDate = datePicker.date
        viewModel.loadCompletedTrackers()
        viewModel.filterTrackersForSelectedDate()
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
        cell.configure(with: tracker, completedDays: daysCount)
        
        cell.onToggleCompleted = { [weak self] in
            guard let self = self, self.viewModel.currentDate <= Date() else { return }
            self.toggleTrackerCompleted(trackerId: tracker.id, at: indexPath)
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

// MARK: - TrackerCreationDelegate

extension TrackersViewController: TrackerCreationDelegate {
    func trackerCreated(_ tracker: Tracker, category: String) {
        viewModel.addTracker(tracker, to: category)
        trackersCollectionView.reloadData()
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
