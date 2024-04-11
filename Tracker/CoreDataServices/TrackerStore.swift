//
//  TrackerStore.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation
import CoreData

final class TrackerStore {
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func createTracker(name: String, color: String, emoji: String, schedule: ReccuringSchedule?) {
            let tracker = TrackerCoreData(context: managedObjectContext)
            tracker.id = UUID()
            tracker.name = name
            tracker.color = color
            tracker.emoji = emoji
        tracker.schedule = schedule
                
                CoreDataStack.shared.saveContext()
            }
}
