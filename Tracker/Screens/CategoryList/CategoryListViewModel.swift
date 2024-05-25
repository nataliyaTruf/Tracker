//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/05/2024.
//

import Foundation


enum ViewState {
    case empty
    case populated
}

final class CategoryListViewModel {
    // MARK: - Properties
    
    var categories: [TrackerCategory] = []{
        didSet {
            updateViewState()
        }
    }
    
    var selectedCategory: TrackerCategory?
    var selectedIndex: IndexPath?
    
    // MARK: - Closures
    
    var onCategorySelected: ((String) -> Void)?
    var onViewStateUpdated: ((ViewState) -> Void)?
    
    private(set) var viewState: ViewState = .empty {
        didSet {
            onViewStateUpdated?(viewState)
        }
    }
    private let categoryStore = CoreDataStack.shared.trackerCategoryStore
    
    // MARK: - Initialization
    
    init() {
        loadCategories()
    }
    
    // MARK: - Methods
    
    func loadCategories() {
        categories = categoryStore.getAllCategoriesWithTrackers()
        updateViewState()
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        selectedIndex = IndexPath(row: index, section: 0)
        onCategorySelected?(selectedCategory?.title ?? "По умолчанию")
    }
    
    private func updateViewState() {
        let state: ViewState = categories.isEmpty ? .empty : .populated
        onViewStateUpdated?(state)
    }
}
