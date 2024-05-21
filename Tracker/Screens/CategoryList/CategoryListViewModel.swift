//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/05/2024.
//

import Foundation


final class CategoryListViewModel {
    // MARK: - Properties
    
    private let categoryStore = CoreDataStack.shared.trackerCategoryStore
    
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
    
    // MARK: - Initialization
    
    init() {
        loadCategories()
    }
    
    // MARK: - Methods
    
    func loadCategories() {
        categories = categoryStore.getAllCategoriesWithTrackers()
    }
    
    func addCategory(name: String) {
        categoryStore.createCategory(title: name)
        loadCategories()
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        selectedIndex = IndexPath(row: index, section: 0)
        onCategorySelected?(selectedCategory?.title ?? "По умолчанию")
    }
}
