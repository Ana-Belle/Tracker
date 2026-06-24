//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 27.05.2026.
//

import CoreData

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Properties
    
    var categories: [TrackerCategory] {
        guard let fetchedResultsController else { return [] }
        return (fetchedResultsController.fetchedObjects ?? []).map { $0.toDomain() }
    }
    
    // MARK: - Public Methods
    
    func performFetch() throws {
        guard let fetchedResultsController else { return }
        try fetchedResultsController.performFetch()
        notifyDelegate()
    }
    
    @discardableResult
    func addCategory(header: String) throws -> TrackerCategory {
        if let existingCategory = fetchCategoryCoreData(forHeader: header) {
            return existingCategory.toDomain()
        }
        
        let category = TrackerCategoryCoreData(context: context)
        category.header = header
        
        try saveContext()
        return category.toDomain()
    }
    
    func fetchCategoryCoreData(forHeader header: String) -> TrackerCategoryCoreData? {
        guard let fetchedResultsController else { return nil }
        return fetchedResultsController.fetchedObjects?.first { $0.header == header }
    }
    
    func updateCategory(oldHeader: String, newHeader: String) throws {
        let trimmedHeader = newHeader.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedHeader.isEmpty && trimmedHeader != oldHeader else { return }
        
        guard let category = fetchCategoryCoreData(forHeader: oldHeader) else {
            throw StoreError.categoryNotFound
        }
        
        if let existingCategory = fetchCategoryCoreData(forHeader: trimmedHeader),
           existingCategory != category {
            return
        }
        
        category.header = trimmedHeader
        try saveContext()
    }
    
    func deleteCategory(header: String) throws {
        guard let category = fetchCategoryCoreData(forHeader: header) else {
            throw StoreError.categoryNotFound
        }
        
        let trackers = category.trackers as? Set<TrackerCoreData> ?? []
        for tracker in trackers {
            let records = tracker.records as? Set<TrackerRecordCoreData> ?? []
            records.forEach { context.delete($0) }
            context.delete(tracker)
        }
        
        context.delete(category)
        try saveContext()
    }
    
    // MARK: - Private Methods
    
    private func setupFetchedResultsController() {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "header", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        guard let fetchedResultsController else { return }
        fetchedResultsController.delegate = self
        
        do {
            try performFetch()
        } catch {
            assertionFailure("Failed to perform initial fetch: \(error)")
        }
    }
    
    private func notifyDelegate() {
        delegate?.trackerCategoryStore(self, didUpdate: categories)
    }
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            throw StoreError.saveFailed(error)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyDelegate()
    }
}

// MARK: - Domain Mapping

extension TrackerCategoryCoreData {
    
    func toDomain() -> TrackerCategory {
        let domainTrackers = (trackers as? Set<TrackerCoreData> ?? [])
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
            .map { $0.toDomain() }
        
        return TrackerCategory(header: header ?? "", trackers: domainTrackers)
    }
}
