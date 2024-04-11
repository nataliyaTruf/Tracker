//
//  TrackerCategryStore.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation
import CoreData

final class TrackerCategoryStore {
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func createCategory(title: String) {
           let category = TrackerCategoryCoreData(context: managedObjectContext)
           category.title = title
        CoreDataStack.shared.saveContext()
       }
}
