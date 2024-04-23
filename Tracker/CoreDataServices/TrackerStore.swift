//
//  TrackerStore.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation
import CoreData

// MARK: - Protocols

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}

// MARK: - Main Class

final class TrackerStore: NSObject {
    // MARK: - Delegate
    
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Properties
    
    private let managedObjectContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
  
    // MARK: - Initialization
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup Methods
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
   
    // MARK: - Public Methods
    
    func createTracker(id: UUID, name: String, color: String, emoji: String, schedule: ReccuringSchedule?) -> Tracker {
        let newTrackerCoreData = TrackerCoreData(context: managedObjectContext)
        newTrackerCoreData.id = UUID()
        newTrackerCoreData.name = name
        newTrackerCoreData.color = color
        newTrackerCoreData.emoji = emoji
        
        if let schedule = schedule {
            do {
                let jsonData = try JSONEncoder().encode(schedule)
                print("🔵 TrackerStore - Encoded JSON Data: \(jsonData)")
                newTrackerCoreData.schedule = jsonData as NSObject
            } catch {
                print("🔴 TrackerStore - Error encoding schedule: \(error)")
            }
        }
        
        saveContext()
        return convertToTrackerModel(coreDataTracker: newTrackerCoreData)
    }
    
    func getCurrentTrackers() -> [TrackerCoreData] {
        let trackers = fetchedResultsController.fetchedObjects ?? []
        return trackers
    }
  
    func convertToTrackerModel(coreDataTracker: TrackerCoreData) -> Tracker {
        var schedule: ReccuringSchedule? = nil
        
        if let scheduleData = coreDataTracker.schedule as? Data {
            do {
                schedule = try JSONDecoder().decode(ReccuringSchedule.self, from: scheduleData)
                print("🔵 TrackerStore - Decoded Schedule: \(String(describing: schedule))")
            } catch {
                print("🔴 TrackerStore - Error decoding schedule: \(error)")
            }
        }
        
        return Tracker(
            id: coreDataTracker.id ?? UUID(),
            name: coreDataTracker.name ?? "Что-то хорошее",
            color: coreDataTracker.color ?? "colorSelection6",
            emodji: coreDataTracker.emoji ?? "🦖",
            schedule: schedule
        )
    }
    
    
    // MARK: - Private Methods
    
    private func saveContext() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        if context.hasChanges {
            context.registeredObjects.forEach { managedObject in
                if managedObject.hasChanges {
                    print("Изменённый объект: \(managedObject.entity.name ?? "Unknown Entity"), Статус: \(managedObject.changedValues())")
                }
            }
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Failed to save context \(nserror), \(nserror.userInfo)")
            }
        } else {
            print("No context to save")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}
