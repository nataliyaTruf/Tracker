//
//  CreateTrackerViewModel.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/05/2024.
//

import UIKit
import Combine

final class CreateTrackerViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var trackerName: String = ""
    @Published var selectedEmojiIndex: Int?
    @Published var selectedColorIndex: Int?
    @Published var selectedCategoryName: String?
    @Published var selectedSchedule: ReccuringSchedule?
    
    // MARK: - Properties
    
    var emojis: [String] = [
        "😀", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    var colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5,
        .colorSelection6, .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10,
        .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    let trackerStore = CoreDataStack.shared.trackerStore
    let trackerRecordStore = CoreDataStack.shared.trackerRecordStore
    private let trackerCategoryStore = CoreDataStack.shared.trackerCategoryStore
    
    // MARK: - Methods
    
    func updateTrackerName(_ name: String) {
        trackerName = name
    }
    
    func selectEmoji(at index: Int) {
        selectedEmojiIndex = index
    }
    
    func selectColor(at index: Int) {
        selectedColorIndex = index
    }
    
    func selectCategory(name: String) {
        selectedCategoryName = name
    }
    
    func createOrUpdateTracker(isEditingMode: Bool, existingTrackerId: UUID? = nil) -> Tracker? {
        let selectedEmoji = selectedEmojiIndex != nil ? emojis[selectedEmojiIndex!] : (emojis.randomElement() ?? L10n.defaultEmoji)
        let selectedColor = selectedColorIndex != nil ? colors[selectedColorIndex!] : (colors.randomElement() ?? .colorSelection6)
        let selectedColorString = UIColor.string(from: selectedColor) ?? L10n.defaultColor
        
        if isEditingMode, let existingTrackerId = existingTrackerId {
            return trackerStore.updateTracker(
                id: existingTrackerId,
                name: trackerName.isEmpty ? L10n.defaultGoodThing : trackerName,
                color: selectedColorString,
                emoji: selectedEmoji,
                schedule: selectedSchedule,
                categoryTitle: selectedCategoryName ?? L10n.defaultCategory
            )
        } else {
            let newTracker = trackerStore.createTracker(
                id: UUID(),
                name: trackerName.isEmpty ? L10n.defaultGoodThing : trackerName,
                color: selectedColorString,
                emoji: selectedEmoji,
                schedule: selectedSchedule,
                categoryTitle: selectedCategoryName ?? L10n.defaultCategory
            )
            
            if let newTrackerCoreData = trackerStore.fetchTrackerCoreData(by: newTracker.id) {
                trackerCategoryStore.linkTracker(newTrackerCoreData, toCategoryWithTitle: selectedCategoryName ?? L10n.defaultCategory)
            }
            
            return newTracker
        }
    }
}
