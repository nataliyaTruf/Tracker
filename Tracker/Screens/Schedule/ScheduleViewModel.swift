//
//  ScheduleViewModel.swift
//  Tracker
//
//  Created by Natasha Trufanova on 22/05/2024.
//

import Foundation
import Combine


final class ScheduleViewModel {
    // MARK: - Input
    
    @Published var selectedDays: [Weekday] = []
    
    // MARK: - Output
    
    var onScheduleUpdated: ((ReccuringSchedule) -> Void)?
    
    // MARK: - Additional properties
    
    var schedule: ReccuringSchedule
    let days: [Weekday]
    var trackerStore: TrackerStore?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(schedule: ReccuringSchedule, trackerStore: TrackerStore?) {
        self.schedule = schedule
        self.trackerStore = trackerStore
        self.days = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        self.selectedDays = schedule.recurringDays.compactMap { Weekday(rawValue: $0) }
        
        $selectedDays
            .sink { [weak self] days in
                self?.updatedSchedule(with: days)
            }
            .store(in: &cancellables)
    }
    private func updatedSchedule(with days: [Weekday]) {
        let updatedDays = days.map { $0.rawValue }
        let updatedSchedule = ReccuringSchedule(recurringDays: updatedDays)
        onScheduleUpdated?(updatedSchedule)
    }
}
