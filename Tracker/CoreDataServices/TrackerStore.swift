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
    func trackerStoreDidChangeContent()
}

// MARK: - Main Class

final class TrackerStore: NSObject {
    // MARK: - Delegate
    
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Properties
    
    private let managedObjectContext: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    // MARK: - Initialization
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        self.categoryStore = TrackerCategoryStore(managedObjectContext: managedObjectContext)
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    
    func createTracker(id: UUID, name: String, color: String, emoji: String, schedule: ReccuringSchedule?, categoryTitle: String) -> Tracker {
        let newTrackerCoreData = TrackerCoreData(context: managedObjectContext)
        newTrackerCoreData.id = UUID()
        newTrackerCoreData.name = name
        newTrackerCoreData.color = color
        newTrackerCoreData.emoji = emoji
        
        newTrackerCoreData.creationDate = Date()
        
        if let schedule = schedule {
            do {
                let scheduleData = try JSONEncoder().encode(schedule)
                newTrackerCoreData.schedule = scheduleData as NSObject
            } catch {
                print("TrackerStore - Error encoding schedule: \(error)")
            }
        }
        let category = categoryStore.createCategoryIfNotExists(with: categoryTitle)
        newTrackerCoreData.category = category
        category.addToTrackers(newTrackerCoreData)
        
        saveContext()
        return convertToTrackerModel(coreDataTracker: newTrackerCoreData)
    }
    
    func fetchTrackerCoreData(by id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            return try managedObjectContext.fetch(fetchRequest).first
        } catch {
            print("TrackerStore - Error fetching TrackerCoreData: \(error)")
            return nil
        }
    }
    
    func getCurrentTrackers() -> [Tracker] {
        let trackersCoreData = fetchedResultsController.fetchedObjects ?? []
        return trackersCoreData.map { convertToTrackerModel(coreDataTracker: $0) }
    }
    
    func convertToTrackerModel(coreDataTracker: TrackerCoreData) -> Tracker {
        var schedule: ReccuringSchedule? = nil
        
        if let scheduleData = coreDataTracker.schedule as? Data {
            do {
                schedule = try JSONDecoder().decode(ReccuringSchedule.self, from: scheduleData)
            } catch {
                print("TrackerStore - Error decoding schedule: \(error)")
            }
        }
        
        return Tracker(
            id: coreDataTracker.id ?? UUID(),
            name: coreDataTracker.name ?? L10n.defaultGoodThing,
            color: coreDataTracker.color ?? L10n.defaultColor,
            emodji: coreDataTracker.emoji ?? L10n.defaultEmoji,
            schedule: schedule,
            creationDate: coreDataTracker.creationDate ?? Date()
        )
    }
    
    func deleteTracker(trackerId: UUID) {
        if let trackerCoreData = fetchTrackerCoreData(by: trackerId) {
            managedObjectContext.delete(trackerCoreData)
            saveContext()
        }
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
        delegate?.trackerStoreDidChangeContent()
    }
}
