//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate(records: [TrackerRecord])
}

final class TrackerRecordStore: NSObject {
    private let managedObjectContext: NSManagedObjectContext
    weak var delegate: TrackerRecordStoreDelegate?
    private var fetchedResultController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
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
    
    func getAllRecords() -> [TrackerRecord] {
        return (fetchedResultController.fetchedObjects ?? []).map(convertToTrackerRecordModel)
    }
    
    private func convertToTrackerRecordModel(coreDataRecord: TrackerRecordCoreData) -> TrackerRecord {
        return TrackerRecord(id: coreDataRecord.id!, date: coreDataRecord.date!)
    }
    
    private func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                delegate?.trackerRecordStoreDidUpdate(records: getAllRecords())
            } catch {
                print("Failed to save context: \(error)")            }
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let recordsCoreData = controller.fetchedObjects as? [TrackerRecordCoreData] else { return }
        let records = recordsCoreData.map { self.convertToTrackerRecordModel(coreDataRecord: $0) }
        delegate?.trackerRecordStoreDidUpdate(records: records)
    }
}
