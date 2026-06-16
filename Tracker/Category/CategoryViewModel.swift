//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 11.06.2026.
//

import Foundation

struct CategoryCellModel {
    let header: String
    let isSelected: Bool
}

final class CategoryViewModel {
    
    // MARK: - Bindings
    
    var onCategoriesUpdated: (() -> Void)?
    var onEmptyStateChanged: ((Bool) -> Void)?
    var onDismiss: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onPresentAddCategory: (() -> Void)?
    var onPresentEditCategory: ((String) -> Void)?
    var onShowDeleteConfirmation: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Properties
    
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = []
    private(set) var selectedCategoryHeader: String?
    
    // MARK: - Initialization
    
    init(
        categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        selectedCategoryHeader: String? = nil
    ) {
        self.categoryStore = categoryStore
        self.selectedCategoryHeader = selectedCategoryHeader
        self.categories = categoryStore.categories
        categoryStore.delegate = self
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        onEmptyStateChanged?(categories.isEmpty)
        onCategoriesUpdated?()
    }
    
    // MARK: - Table View
    
    var numberOfCategories: Int {
        categories.count
    }
    
    func cellModel(at index: Int) -> CategoryCellModel? {
        guard categories.indices.contains(index) else { return nil }
        
        let category = categories[index]
        
        return CategoryCellModel(
            header: category.header,
            isSelected: category.header == selectedCategoryHeader
        )
    }
    
    func header(at index: Int) -> String {
        categories[index].header
    }
    
    // MARK: - Actions
    
    func selectCategory(at index: Int) {
        let header = categories[index].header
        selectedCategoryHeader = header
        onCategoriesUpdated?()
        onCategorySelected?(header)
        onDismiss?()
    }
    
    func addButtonTapped() {
        onPresentAddCategory?()
    }
    
    func editCategory(header: String) {
        onPresentEditCategory?(header)
    }
    
    func deleteCategory(header: String) {
        onShowDeleteConfirmation?(header)
    }
    
    func confirmDeleteCategory(header: String) {
        do {
            try categoryStore.deleteCategory(header: header)
            if selectedCategoryHeader == header {
                selectedCategoryHeader = nil
            }
        } catch {
            onError?("Не удалось удалить категорию: \(error)")
        }
    }
    
    func categoryUpdated(oldHeader: String, newHeader: String) {
        if selectedCategoryHeader == oldHeader {
            selectedCategoryHeader = newHeader
            onCategoriesUpdated?()
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate categories: [TrackerCategory]) {
        self.categories = categories
        onEmptyStateChanged?(categories.isEmpty)
        onCategoriesUpdated?()
    }
}
