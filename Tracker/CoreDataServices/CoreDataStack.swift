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
        
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Store Accessors
    
    private(set) lazy var trackerStore: TrackerStore = {
        return TrackerStore(managedObjectContext: persistentContainer.viewContext)
    }()
    
    private(set) lazy var trackerCategoryStore: TrackerCategoryStore = {
        return TrackerCategoryStore(managedObjectContext: persistentContainer.viewContext)
    }()
    
    private(set) lazy var trackerRecordStore: TrackerRecordStore = {
        return TrackerRecordStore(managedObjectContext: persistentContainer.viewContext)
    }()
}
