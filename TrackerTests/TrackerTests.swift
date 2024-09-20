//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Natasha Trufanova on 13/06/2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker


final class TrackerTests: XCTestCase {
    func testTrackersViewControllerLight() {
        let viewModel = TrackersViewModel()
        viewModel.categories = [
            TrackerCategory(title: "Test Category", trackers: [
                Tracker(id: UUID(), name: "Теннис", color: "colorSelection5", emodji: "🎾", schedule: ReccuringSchedule(recurringDays: [Weekday.thursday.rawValue]), creationDate: Date(), originalCategory: nil)
            ])
        ]
        viewModel.filteredCategories = viewModel.categories
        
        let vc = TrackersViewController()
        vc.viewModel = viewModel
        
        let record = false
        assertSnapshot(of: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)), record: record)
    }
    
    // Добавляем тест для темной темы
    func testTrackersViewControllerDark() {
        let viewModel = TrackersViewModel()
        viewModel.categories = [
            TrackerCategory(title: "Test Category", trackers: [
                Tracker(id: UUID(), name: "Теннис", color: "colorSelection5", emodji: "🎾", schedule: ReccuringSchedule(recurringDays: [Weekday.thursday.rawValue]), creationDate: Date(), originalCategory: nil)
            ])
        ]
        viewModel.filteredCategories = viewModel.categories
        
        let vc = TrackersViewController()
        vc.viewModel = viewModel
        
        let record = false
        assertSnapshot(of: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)), record: record)
    }
}
