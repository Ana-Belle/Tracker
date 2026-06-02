//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 27.05.2026.
//

import CoreData

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    // MARK: - Initialization
    
    init(
        context: NSManagedObjectContext = CoreDataManager.shared.viewContext,
        trackerStore: TrackerStore? = nil
    ) {
        self.context = context
        self.trackerStore = trackerStore ?? TrackerStore(context: context)
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Properties
    
    var records: [TrackerRecord] {
        guard let fetchedResultsController else { return [] }
        return (fetchedResultsController.fetchedObjects ?? []).compactMap { $0.toDomain() }
    }
    
    // MARK: - Public Methods
    
    func performFetch() throws {
        guard let fetchedResultsController else { return }
        try fetchedResultsController.performFetch()
        notifyDelegate()
    }
    
    func fetchRecords(for trackerId: UUID) -> [TrackerRecord] {
        records.filter { $0.id == trackerId }
    }
    
    func fetchRecords(for date: Date) -> [TrackerRecord] {
        records.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func isTrackerCompleted(trackerId: UUID, on date: Date) -> Bool {
        records.contains {
            $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func completedDaysCount(for trackerId: UUID) -> Int {
        records.filter { $0.id == trackerId }.count
    }
    
    @discardableResult
    func addRecord(trackerId: UUID, date: Date) throws -> TrackerRecord {
        guard let tracker = trackerStore.fetchTrackerCoreData(id: trackerId) else {
            throw StoreError.trackerNotFound
        }
        
        if let existingRecord = fetchRecordCoreData(trackerId: trackerId, date: date),
           let domainRecord = existingRecord.toDomain() {
            return domainRecord
        }
        
        let record = TrackerRecordCoreData(context: context)
        record.id = UUID()
        record.date = normalizedDate(date)
        record.tracker = tracker
        
        try saveContext()
        return TrackerRecord(id: trackerId, date: record.date ?? date)
    }
    
    func deleteRecord(trackerId: UUID, date: Date) throws {
        guard let record = fetchRecordCoreData(trackerId: trackerId, date: date) else {
            return
        }
        
        context.delete(record)
        try saveContext()
    }
    
    // MARK: - Private Methods
    
    private func fetchRecordCoreData(trackerId: UUID, date: Date) -> TrackerRecordCoreData? {
        fetchedResultsController?.fetchedObjects?.first {
            $0.tracker?.id == trackerId
            && Calendar.current.isDate($0.date ?? Date.distantPast, inSameDayAs: date)
        }
    }
    
    private func setupFetchedResultsController() {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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
        delegate?.trackerRecordStore(self, didUpdate: records)
    }
    
    private func normalizedDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
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

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyDelegate()
    }
}

// MARK: - Domain Mapping

extension TrackerRecordCoreData {
    
    func toDomain() -> TrackerRecord? {
        guard let trackerId = tracker?.id, let date else { return nil }
        return TrackerRecord(id: trackerId, date: date)
    }
}
