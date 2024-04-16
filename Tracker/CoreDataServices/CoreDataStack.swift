//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation
import CoreData

final class CoreDataStack {
    // MARK: - Core Data stack
    
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Store Accessors
    
    var trackerStore: TrackerStore {
        return TrackerStore(managedObjectContext: persistentContainer.viewContext)
    }
    
    var trackerCategoryStore: TrackerCategoryStore {
        return TrackerCategoryStore(managedObjectContext: persistentContainer.viewContext)
    }
    
    var trackerRecordStore: TrackerRecordStore {
        return TrackerRecordStore(managedObjectContext: persistentContainer.viewContext)
    }
}
