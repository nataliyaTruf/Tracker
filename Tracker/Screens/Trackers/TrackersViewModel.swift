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
    @Published var filteredCategories: [TrackerCategory] = []
    @Published var completedTrackers: [TrackerRecord] = []
    @Published var completedTrackerIds = Set<UUID>()
    @Published var currentDate: Date = Date()
    @Published var isSearching = false
    
    // MARK: - Properties
    
    private let trackerCategoryStore = CoreDataStack.shared.trackerCategoryStore
    private let trackerStore = CoreDataStack.shared.trackerStore
    private let trackerRecordStore = CoreDataStack.shared.trackerRecordStore
    private var trackerCreationDates: [UUID : Date] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init() {
        loadCategories()
        loadCompletedTrackers()
    }
    
    // MARK: - Methods
    
    func loadCategories() {
        categories = trackerCategoryStore.getAllCategoriesWithTrackers()
        filterTrackersForSelectedDate()
    }
    
    func loadCompletedTrackers() {
        completedTrackers = trackerRecordStore.getAllRecords()
        completedTrackerIds = Set(completedTrackers.map { $0.id })
        filterTrackersForSelectedDate()
    }
    
    func toggleTrackerCompleted(trackerId: UUID) {
        if isTrackerCompletedOnCurrentDate(trackerId: trackerId) {
            CoreDataStack.shared.trackerRecordStore.deleteRecord(trackerId: trackerId, date: currentDate)
            completedTrackerIds.remove(trackerId)
            completedTrackers.removeAll {$0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate)}
        } else {
            CoreDataStack.shared.trackerRecordStore.createRecord(trackerId: trackerId, date: currentDate)
            completedTrackerIds.insert(trackerId)
            let newRecord = TrackerRecord(id: trackerId, date: currentDate)
            completedTrackers.append(newRecord)
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
    
    func addTracker(_ tracker: Tracker, to category: String) {
        if let index = categories.firstIndex(where: { $0.title == category }) {
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)
            categories[index] = TrackerCategory(title: category, trackers: updatedTrackers)
        } else {
            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            categories.append(newCategory)
        }
        
        trackerCreationDates[tracker.id] = Date()
        filterTrackersForSelectedDate() // ??
    }
    
    func filterTrackersForSelectedDate() {
        let dayOfWeek = currentDate.toWeekday()
        
        filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                if let schedule = tracker.schedule {
                    return schedule.isReccuringOn(dayOfWeek)
                } else {
                    if let creationDate = trackerCreationDates[tracker.id] {
                        return !completedTrackerIds.contains(tracker.id) && Calendar.current.isDate(currentDate, inSameDayAs: creationDate)
                    }
                    return false
                }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
}
