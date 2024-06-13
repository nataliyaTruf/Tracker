//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/05/2024.
//

import Foundation
import Combine


final class TrackersViewModel {
    
    // MARK: - Published Properties
    
    @Published var categories: [TrackerCategory] = []
    @Published var filteredCategories: [TrackerCategory] = [] {
        didSet {
            updateViewState()
        }
    }
    @Published var completedTrackers: [TrackerRecord] = []
    @Published var completedTrackerIds = Set<UUID>()
    @Published var currentDate: Date = Date()
    @Published var isSearching = false {
        didSet {
            updateViewState()
        }
    }
    @Published var viewState: ViewState = .empty
    @Published var selectedFilter: TrackerFilter = .all {
        didSet {
            saveSelectedFilter()
            filterTrackersForSelectedDate()
            updateViewState()
        }
    }
    
    // MARK: - Properties
    var trackerCreationDates: [UUID : Date] = [:]
    private let trackerCategoryStore = CoreDataStack.shared.trackerCategoryStore
    private let trackerStore = CoreDataStack.shared.trackerStore
    private let trackerRecordStore = CoreDataStack.shared.trackerRecordStore
    private let completedTrackersKey = "completedTrackersCount"
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        loadSelectedFilter()
        loadCategories()
        loadCompletedTrackers()
        updateCompletedTrackersCount()
    }
    
    // MARK: - Data Loading
    
    func loadCategories() {
        categories = trackerCategoryStore.getAllCategoriesWithTrackers()
        for category in categories {
            for tracker in category.trackers {
                trackerCreationDates[tracker.id] = tracker.creationDate
            }
        }
        
        filterTrackersForSelectedDate()
        updateViewState()
    }
    
    func loadCompletedTrackers() {
        completedTrackers = trackerRecordStore.getAllRecords()
        completedTrackerIds = Set(completedTrackers.map { $0.id })
        filterTrackersForSelectedDate()
        updateViewState()
    }
    
    // MARK: - Task Completion
    
    func toggleTrackerCompleted(trackerId: UUID) {
        if isTrackerCompletedOnCurrentDate(trackerId: trackerId) {
            CoreDataStack.shared.trackerRecordStore.deleteRecord(trackerId: trackerId, date: currentDate)
            completedTrackerIds.remove(trackerId)
            completedTrackers.removeAll {$0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate)}
            updateCompletedTrackersCount(decrement: true)
        } else {
            CoreDataStack.shared.trackerRecordStore.createRecord(trackerId: trackerId, date: currentDate)
            completedTrackerIds.insert(trackerId)
            let newRecord = TrackerRecord(id: trackerId, date: currentDate)
            completedTrackers.append(newRecord)
            updateCompletedTrackersCount(increment: true)
        }
    }
    
    func isTrackerCompletedOnCurrentDate(trackerId: UUID) -> Bool {
        return completedTrackers.contains(where: { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate)})
    }
    
    func countCompletedDays(for trackerId: UUID) -> Int {
        let completedDates = completedTrackers.filter { $0.id == trackerId }.map { $0.date }
        let uniquesDates = Set(completedDates)
        return uniquesDates.count
    }
    
    // MARK: - Filtering
    
    func filterTrackersForSelectedDate() {
        let dayOfWeek = currentDate.toWeekday()
        
        filteredCategories = categories.map { category in
            let filteredTrackers: [Tracker]
            
            switch selectedFilter {
                
            case .all:
                filteredTrackers = category.trackers.filter { tracker in
                    if let schedule = tracker.schedule {
                        return schedule.isReccuringOn(dayOfWeek)
                    } else {
                        if let creationDate = trackerCreationDates[tracker.id] {
                            return Calendar.current.isDate(currentDate, inSameDayAs: creationDate)
                        }
                        return false
                    }
                }
                
            case .today:
                filteredTrackers = category.trackers.filter { tracker in
                    if Calendar.current.isDate(currentDate, inSameDayAs: Date()) {
                        if let schedule = tracker.schedule {
                            return schedule.isReccuringOn(dayOfWeek)
                        } else {
                            if let creationDate = trackerCreationDates[tracker.id] {
                                return Calendar.current.isDate(currentDate, inSameDayAs: creationDate)
                            }
                            return false
                        }
                    } else {
                        return false
                    }
                }
                
            case .completed:
                filteredTrackers = category.trackers.filter { tracker in
                    isTrackerCompletedOnCurrentDate(trackerId: tracker.id) && isTrackerScheduledForCurrentDate(tracker: tracker)
                }
            case .uncompleted:
                filteredTrackers = category.trackers.filter { tracker in
                    !isTrackerCompletedOnCurrentDate(trackerId: tracker.id) && isTrackerScheduledForCurrentDate(tracker: tracker)
                }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
    
    func updateViewState() {
        let hasTrackersToShow = !filteredCategories.flatMap { $0.trackers }.isEmpty
        viewState = hasTrackersToShow ? .populated : .empty
    }
    
    // MARK: - Deletion
    
    func deleteTracker(trackerId: UUID) {
        trackerStore.deleteTracker(trackerId: trackerId)
        resetTrackerStatistics(trackerId: trackerId)
        loadCategories()
        loadCompletedTrackers()
    }
    
    // MARK: - Pinning
    
    func isTrackerPinned(_ tracker: Tracker) -> Bool {
        guard let trackerCoreData = trackerStore.fetchTrackerCoreData(by: tracker.id) else { return false }
        return trackerCoreData.category?.title == "Закрепленные"
    }
    
    func pinTracker(_ tracker: Tracker) {
        print("Pinning tracker: \(tracker.name)")
        trackerCategoryStore.pinTracker(tracker.id)
        loadCategories()
        filterTrackersForSelectedDate()
    }
    
    func unpinTracker(_ tracker: Tracker) {
        print("Unpinning tracker: \(tracker.name)")
        trackerCategoryStore.unpinTracker(tracker.id)
        loadCategories()
        filterTrackersForSelectedDate()
    }
    
    // MARK: - Private methods
    
    private func loadSelectedFilter() {
        if let savedFilter = UserDefaults.standard.string(forKey: "selectedFilter") {
            selectedFilter = TrackerFilter(rawValue: savedFilter) ?? .all
        }
    }
    
    private func saveSelectedFilter() {
        UserDefaults.standard.set(selectedFilter.rawValue, forKey: "selectedFilter")
    }
    
    private func isTrackerScheduledForCurrentDate(tracker: Tracker) -> Bool {
        let dayOfWeek = currentDate.toWeekday()
        if let schedule = tracker.schedule {
            return schedule.isReccuringOn(dayOfWeek)
        } else {
            if let creationDate = trackerCreationDates[tracker.id] {
                return Calendar.current.isDate(currentDate, inSameDayAs: creationDate)
            }
            return false
        }
    }
    
    private func updateCompletedTrackersCount(increment: Bool = false, decrement: Bool = false) {
        var count = UserDefaults.standard.integer(forKey: completedTrackersKey)
        if increment {
            count += 1
        } else if decrement {
            count -= 1
        } else {
            count = completedTrackers.count
        }
        UserDefaults.standard.set(count, forKey: completedTrackersKey)
    }
    
    private func resetTrackerStatistics(trackerId: UUID) {
        completedTrackers.removeAll { $0.id == trackerId }
        completedTrackerIds.remove(trackerId)
        updateCompletedTrackersCount()
    }
}

