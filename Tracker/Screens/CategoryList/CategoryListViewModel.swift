//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/05/2024.
//

import Foundation


final class CategoryListViewModel {
    // MARK: - Properties
    
    var categories: [TrackerCategory] = []{
        didSet {
            self.onCategoriesUpdated?(categories)
        }
    }
    
    var selectedCategory: TrackerCategory?
    var selectedIndex: IndexPath?
    
    // MARK: - Closures
    
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    
    private let categoryStore = CoreDataStack.shared.trackerCategoryStore
    
    // MARK: - Initialization
    
    init() {
        loadCategories()
    }
    
    // MARK: - Methods
    
    func loadCategories() {
        categories = categoryStore.getAllCategoriesWithTrackers()
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        selectedIndex = IndexPath(row: index, section: 0)
        onCategorySelected?(selectedCategory?.title ?? "По умолчанию")
    }
}
