//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation
import CoreData

final class TrackerRecordStore {
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
    }
    func createRecord(trackerId: UUID, date: Date) {
            let record = TrackerRecordCoreData(context: managedObjectContext)
            record.id = UUID()
            record.date = date
        if let tracker = fetchTracker(by: trackerId) {
                    record.tracker = tracker
                }
        CoreDataStack.shared.saveContext()
            }
    
    private func fetchTracker(by id: UUID) -> TrackerCoreData? {
           let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
           
           do {
               let results = try managedObjectContext.fetch(fetchRequest)
               return results.first
           } catch {
               print("Failed to fetch tracker with ID \(id): \(error)")
               return nil
           }
       }
}
