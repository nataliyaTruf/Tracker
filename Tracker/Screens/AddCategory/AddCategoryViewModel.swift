//
//  AddCategoryViewModel.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/05/2024.
//

import Foundation


final class AddCategoryViewModel {
    // MARK: - Closures
    
    var onCategoryAdded: ((String) -> Void)?
    var onDoneButtonStateUpdated: ((Bool) -> Void)?
    var onInvalidCategoryName: ((Bool) -> Void)?
    
    // MARK: - Properties
    
    private let categoryStore = CoreDataStack.shared.trackerCategoryStore
    
    // MARK: - Methods
    
    func addCategory(name: String) {
        categoryStore.createCategory(title: name)
        onCategoryAdded?(name)
    }
    
    func validateCategoryName(_ name: String?) {
        let isNameEntered = !(name?.isEmpty ?? true)
        let isNameInvalid = name?.trimmingCharacters(in: .whitespaces).lowercased() == L10n.pinned.lowercased()
        onDoneButtonStateUpdated?(isNameEntered && !isNameInvalid)
        onInvalidCategoryName?(isNameInvalid)
    }
}
