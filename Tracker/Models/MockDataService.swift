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
        
        let schedule1 = ReccuringSchedule(mondays: true, tuesdays: true, wednesdays: true, thursdays: true, fridays: true, saturdays: true, sundays: false)
        let schedule2 = ReccuringSchedule(mondays: false, tuesdays: true, wednesdays: true, thursdays: false, fridays: false, saturdays: false, sundays: false)
        let schedule3 = ReccuringSchedule(mondays: true, tuesdays: true, wednesdays: false, thursdays: false, fridays: false, saturdays: true, sundays: false)
        
        let tracker1 = Tracker(id: UUID(), name: "Полив растений", color: "colorSelection1", emodji: "🦖", scedule: schedule1)
        let tracker2 = Tracker(id: UUID(), name: "Йога", color: "colorSelection12", emodji: "🧘‍♀️", scedule: schedule2)
        let tracker3 = Tracker(id: UUID(), name: "14 спринт", color: "colorSelection7", emodji: "👹", scedule: schedule3)
        let tracker4 = Tracker(id: UUID(), name: "Теннис", color: "colorSelection5", emodji: "🎾", scedule: nil)
        
        let dummyCategories = [ TrackerCategory(title: "Домашние дела", trackers: [tracker1, tracker2]),
                                TrackerCategory(title: "Здоровье и спорт", trackers: [tracker4]),
                                TrackerCategory(title: "Образование", trackers: [tracker3]) ]
        categories.append(contentsOf: dummyCategories)
    
        return categories        
    }
}
