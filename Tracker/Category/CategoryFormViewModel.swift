//
//  CategoryFormViewModel.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 17.06.2026.
//

import Foundation

final class CategoryFormViewModel {
    
    // MARK: - Bindings
    
    var onTitleUpdated: ((String) -> Void)?
    var onInitialTextUpdated: ((String) -> Void)?
    var onDoneButtonStateChanged: ((Bool) -> Void)?
    var onDismiss: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Properties
    
    private let categoryStore: TrackerCategoryStore
    private let editingCategoryHeader: String?
    private let onCategoryUpdated: ((_ oldHeader: String, _ newHeader: String) -> Void)?
    
    // MARK: - Initialization
    
    init(
        categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        editingCategoryHeader: String? = nil,
        onCategoryUpdated: ((_ oldHeader: String, _ newHeader: String) -> Void)? = nil
    ) {
        self.categoryStore = categoryStore
        self.editingCategoryHeader = editingCategoryHeader
        self.onCategoryUpdated = onCategoryUpdated
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        if let editingCategoryHeader {
            onTitleUpdated?("Редактирование категории")
            onInitialTextUpdated?(editingCategoryHeader)
            updateDoneButtonState(for: editingCategoryHeader)
        } else {
            onTitleUpdated?("Новая категория")
            updateDoneButtonState(for: "")
        }
    }
    
    // MARK: - Actions
    
    func textDidChange(_ text: String) {
        updateDoneButtonState(for: text)
    }
    
    func doneButtonTapped(text: String) {
        let header = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !header.isEmpty else { return }
        
        do {
            if let editingCategoryHeader {
                try categoryStore.updateCategory(oldHeader: editingCategoryHeader, newHeader: header)
                onCategoryUpdated?(editingCategoryHeader, header)
            } else {
                try categoryStore.addCategory(header: header)
            }
            onDismiss?()
        } catch {
            onError?("Не удалось сохранить категорию: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func updateDoneButtonState(for text: String) {
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        onDoneButtonStateChanged?(hasText)
    }
}
