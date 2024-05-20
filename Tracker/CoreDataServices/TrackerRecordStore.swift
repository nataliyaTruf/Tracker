//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation
import CoreData

// MARK: - Protocols

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChangeContent(records: [TrackerRecord])
}

// MARK: - Main Class

final class TrackerRecordStore: NSObject {
    // MARK: - Delegate
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Properties
    
    private let managedObjectContext: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    // MARK: - Initialization
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup Methods
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
        
        fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "TrackerRecordsCache"
        )
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Failed to initialize fetched results controller: \(error)")
        }
        
    }
    
    // MARK: - Public Methods
    
    func createRecord(trackerId: UUID, date: Date) {
        let record = TrackerRecordCoreData(context: managedObjectContext)
        record.id = trackerId
        record.date = date
        if let tracker = fetchTracker(by: trackerId) {
            record.tracker = tracker
        }
        
        saveContext()
        
    }
    
    func deleteRecord(trackerId: UUID, date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            for record in results {
                managedObjectContext.delete(record)
            }
            
            saveContext()
            
        } catch let error as NSError {
            print("Failed delete Record \(error), \(error.userInfo)")
        }
    }

    func getAllRecords() -> [TrackerRecord] {
        return (fetchedResultController.fetchedObjects ?? []).map(convertToTrackerRecordModel)
    }
 
    // MARK: - Private Methods
  
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
    
    
    private func convertToTrackerRecordModel(coreDataRecord: TrackerRecordCoreData) -> TrackerRecord {
        return TrackerRecord(id: coreDataRecord.id!, date: coreDataRecord.date!)
    }
    
    private func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                delegate?.trackerRecordStoreDidChangeContent(records: getAllRecords())
            } catch {
                print("Failed to save context: \(error)")            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let recordsCoreData = controller.fetchedObjects as? [TrackerRecordCoreData] else { return }
        let records = recordsCoreData.map { self.convertToTrackerRecordModel(coreDataRecord: $0) }
        delegate?.trackerRecordStoreDidChangeContent(records: records)
    }
}
