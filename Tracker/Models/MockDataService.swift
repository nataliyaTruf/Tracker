//
//  MockDataService.swift
//  Tracker
//
//  Created by Natasha Trufanova on 12/02/2024.
//

import Foundation


class MockDataService {
    static let shared = MockDataService()
    private var categories: [TrackerCategory] = []
    
    private init() {}
    
    func getDummyTrackers() -> [TrackerCategory] {
        
        if !categories.isEmpty {
            return categories
        }
        
        let schedule1 = ReccuringSchedule(recurringDays: [Weekday.monday.rawValue])
        let schedule2 = ReccuringSchedule(recurringDays: [Weekday.monday.rawValue, Weekday.thursday.rawValue, Weekday.sunday.rawValue])
        let schedule3 = ReccuringSchedule(recurringDays: [Weekday.monday.rawValue, Weekday.wednesday.rawValue, Weekday.friday.rawValue])
        
        let tracker1 = Tracker(id: UUID(), name: "Полив растений", color: "colorSelection1", emodji: "🦖", schedule: schedule1)
        let tracker2 = Tracker(id: UUID(), name: "Йога", color: "colorSelection12", emodji: "🧘‍♀️", schedule: schedule2)
        let tracker3 = Tracker(id: UUID(), name: "14 спринт", color: "colorSelection7", emodji: "👹", schedule: schedule3)
        let tracker4 = Tracker(id: UUID(), name: "Теннис", color: "colorSelection5", emodji: "🎾", schedule: schedule1)
        
        let dummyCategories = [ TrackerCategory(title: "Домашние дела", trackers: [tracker1, tracker2]),
                                TrackerCategory(title: "Здоровье и спорт", trackers: [tracker4]),
                                TrackerCategory(title: "Образование", trackers: [tracker3]) ]
        categories.append(contentsOf: dummyCategories)
    
        return categories        
    }
}
