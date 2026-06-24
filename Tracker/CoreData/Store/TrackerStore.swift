//
//  TrackerStore.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 27.05.2026.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    // MARK: - Initialization
    
    init(
        context: NSManagedObjectContext = CoreDataManager.shared.viewContext,
        categoryStore: TrackerCategoryStore? = nil
    ) {
        self.context = context
        self.categoryStore = categoryStore ?? TrackerCategoryStore(context: context)
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Properties
    
    var trackers: [Tracker] {
        guard let fetchedResultsController else { return [] }
        return (fetchedResultsController.fetchedObjects ?? []).map { $0.toDomain() }
    }
    
    // MARK: - Public Methods
    
    func performFetch() throws {
        guard let fetchedResultsController else { return }
        try fetchedResultsController.performFetch()
        notifyDelegate()
    }
    
    func fetchTrackers(forCategoryHeader header: String) -> [Tracker] {
        guard let fetchedResultsController else { return [] }
        return (fetchedResultsController.fetchedObjects ?? [])
            .filter { $0.category?.header == header }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
            .map { $0.toDomain() }
    }
    
    func fetchTracker(id: UUID) -> Tracker? {
        fetchTrackerCoreData(id: id)?.toDomain()
    }
    
    func addTracker(_ tracker: Tracker, toCategoryHeader header: String) throws {
        let category = categoryStore.fetchCategoryCoreData(forHeader: header)
        ?? {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.header = header
            return newCategory
        }()
        
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.emoji = tracker.emoji
        trackerEntity.color = CoreDataValueCodec.encodeColor(tracker.color)
        trackerEntity.schedule = CoreDataValueCodec.encodeSchedule(tracker.schedule)
        trackerEntity.category = category
        
        try saveContext()
    }
    
    func updateTracker(_ tracker: Tracker, toCategoryHeader header: String) throws {
        guard let trackerEntity = fetchTrackerCoreData(id: tracker.id) else {
            throw StoreError.trackerNotFound
        }
        
        let category = categoryStore.fetchCategoryCoreData(forHeader: header)
        ?? {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.header = header
            return newCategory
        }()
        
        trackerEntity.name = tracker.name
        trackerEntity.emoji = tracker.emoji
        trackerEntity.color = CoreDataValueCodec.encodeColor(tracker.color)
        trackerEntity.schedule = CoreDataValueCodec.encodeSchedule(tracker.schedule)
        trackerEntity.category = category
        
        try saveContext()
    }
    
    func deleteTracker(id: UUID) throws {
        guard let tracker = fetchTrackerCoreData(id: id) else {
            throw StoreError.trackerNotFound
        }
        
        let records = tracker.records as? Set<TrackerRecordCoreData> ?? []
        records.forEach { context.delete($0) }
        context.delete(tracker)
        try saveContext()
    }
    
    func fetchTrackerCoreData(id: UUID) -> TrackerCoreData? {
        fetchedResultsController?.fetchedObjects?.first { $0.id == id }
    }
    
    // MARK: - Private Methods
    
    private func setupFetchedResultsController() {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "category.header", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try performFetch()
        } catch {
            assertionFailure("Failed to perform initial fetch: \(error)")
        }
    }
    
    private func notifyDelegate() {
        delegate?.trackerStore(self, didUpdate: trackers)
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyDelegate()
    }
}

// MARK: - Domain Mapping

extension TrackerCoreData {
    
    func toDomain() -> Tracker {
        Tracker(
            id: id ?? UUID(),
            name: name ?? "",
            color: CoreDataValueCodec.decodeColor(color) ?? .clear,
            emoji: emoji ?? "",
            schedule: CoreDataValueCodec.decodeSchedule(schedule)
        )
    }
}
