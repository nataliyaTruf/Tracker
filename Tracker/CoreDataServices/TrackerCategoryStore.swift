//
//  TrackerCategryStore.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation
import CoreData

// MARK: - Protocols

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChangeContent(_ store: TrackerCategoryStore)
}

// MARK: - Main Class

final class TrackerCategoryStore: NSObject {
    // MARK: - Delegate
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Properties
    
    private let managedObjectContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    // MARK: - Initialization
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    
    func createCategory(title: String) {
        if fetchCategory(by: title) == nil {
            let category = TrackerCategoryCoreData(context: managedObjectContext)
            category.title = title
            saveContext()
        }
    }
    
    func createCategoryIfNotExists(with title: String) -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        do {
            let fetchedCategories = try managedObjectContext.fetch(fetchRequest)
            if let existingCategory = fetchedCategories.first {
                return existingCategory
            } else {
                let newCategory = TrackerCategoryCoreData(context: managedObjectContext)
                newCategory.title = title
                try managedObjectContext.save()
                return newCategory
            }
        } catch {
            fatalError("Failed to fetch or create category: \(error)")
        }
    }
    
    func linkTracker(_ tracker: TrackerCoreData, toCategoryWithTitle title: String) {
        if let category = fetchCategory(by: title) {
            tracker.category = category
        } else {
            let newCategory = TrackerCategoryCoreData(context:  managedObjectContext)
            newCategory.title = title
            tracker.category = newCategory
        }
        saveContext()
    }
    
    func getAllCategoriesWithTrackers() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let categoriesCoreData = try managedObjectContext.fetch(fetchRequest)
            return categoriesCoreData.map { convertToTrackerCategoryModel(coreDataCategory: $0) }
        } catch {
            print("Failed to fetch categories with trackers: \(error)")
            return []
        }
    }
    
    func fetchCategory(by title: String) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        return try? managedObjectContext.fetch(request).first
    }
    
    func convertToTrackerCategoryModel(coreDataCategory: TrackerCategoryCoreData) -> TrackerCategory {
        let trackers = (coreDataCategory.trackers?.allObjects as? [TrackerCoreData] ?? []).map { trackerCoreData in
            let schedule: ReccuringSchedule? = {
                if let scheduleData = trackerCoreData.schedule as? Data {
                    return try? JSONDecoder().decode(ReccuringSchedule.self, from: scheduleData)
                }
                return nil
            }()
            
            return Tracker(id: trackerCoreData.id ?? UUID(),
                           name: trackerCoreData.name ?? "Что-то хорошее",
                           color: trackerCoreData.color ?? "colorSelection6",
                           emodji: trackerCoreData.emoji ?? "🦖",
                           schedule: schedule)
        }
        return TrackerCategory(title: coreDataCategory.title ?? "По умолчанию", trackers: trackers)
    }
    
    // MARK: - Setup Methods
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
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
            print("Failed to fetch categories: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Failed to save context: \(error)")            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore:  NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidChangeContent(self)
    }
}
