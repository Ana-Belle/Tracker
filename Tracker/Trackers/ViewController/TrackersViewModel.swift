//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 17.06.2026.
//

import Foundation
import UIKit

struct TrackerCellViewModel {
    let tracker: Tracker
    let isCompletedToday: Bool
    let completedDays: Int
}

final class TrackersViewModel {
    
    // MARK: - Bindings
    
    var onContentVisibilityChanged: ((Bool) -> Void)?
    var onCollectionViewReloadData: (() -> Void)?
    var onCollectionViewReloadItems: ((IndexPath) -> Void)?
    var onPresentNewTracker: (() -> Void)?
    var onLogInfo: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Properties
    
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    private var categories: [TrackerCategory] = []
    private(set) var selectedDate = Date()
    
    private var filteredCategories: [TrackerCategory] {
        let weekDay = weekDay(from: selectedDate)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: selectedDate)
        
        if selectedDay > today {
            return []
        }
        
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(weekDay)
            }
            
            if !filteredTrackers.isEmpty {
                return TrackerCategory(header: category.header, trackers: filteredTrackers)
            }
            return nil
        }
    }
    
    private var hasTrackersToDisplay: Bool {
        !filteredCategories.isEmpty && filteredCategories.contains { !$0.trackers.isEmpty }
    }
    
    // MARK: - Initialization
    
    init(
        categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        trackerStore: TrackerStore? = nil,
        recordStore: TrackerRecordStore? = nil
    ) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore ?? TrackerStore(categoryStore: categoryStore)
        self.recordStore = recordStore ?? TrackerRecordStore(trackerStore: self.trackerStore)
        
        self.categories = categoryStore.categories
        self.categoryStore.delegate = self
        self.trackerStore.delegate = self
        self.recordStore.delegate = self
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        updateContentVisibility()
    }
    
    // MARK: - Collection View
    
    var numberOfSections: Int {
        filteredCategories.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        filteredCategories[section].trackers.count
    }
    
    func sectionTitle(for section: Int) -> String {
        filteredCategories[section].header
    }
    
    func cellViewModel(at indexPath: IndexPath) -> TrackerCellViewModel? {
        guard indexPath.section < filteredCategories.count,
              indexPath.item < filteredCategories[indexPath.section].trackers.count else {
            return nil
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        return TrackerCellViewModel(
            tracker: tracker,
            isCompletedToday: recordStore.isTrackerCompleted(trackerId: tracker.id, on: selectedDate),
            completedDays: recordStore.completedDaysCount(for: tracker.id)
        )
    }
    
    // MARK: - Actions
    
    func plusButtonTapped() {
        onPresentNewTracker?()
    }
    
    func dateChanged(_ date: Date) {
        selectedDate = date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        onLogInfo?("Выбранная дата: \(dateFormatter.string(from: date))")
        
        updateContentVisibility()
    }
    
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        do {
            try recordStore.addRecord(trackerId: id, date: selectedDate)
            onCollectionViewReloadItems?(indexPath)
        } catch {
            onError?("Не удалось сохранить выполнение трекера: \(error)")
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        do {
            try recordStore.deleteRecord(trackerId: id, date: selectedDate)
            onCollectionViewReloadItems?(indexPath)
        } catch {
            onError?("Не удалось удалить выполнение трекера: \(error)")
        }
    }
    
    var trackersCount: UInt {
        UInt(trackerStore.trackers.count)
    }
    
    func addNewTrackerToCategory(tracker: Tracker, to categoryHeader: String) {
        do {
            try categoryStore.addCategory(header: categoryHeader)
            try trackerStore.addTracker(tracker, toCategoryHeader: categoryHeader)
        } catch {
            onError?("Не удалось сохранить трекер: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func updateContentVisibility() {
        onContentVisibilityChanged?(hasTrackersToDisplay)
        onCollectionViewReloadData?()
    }
    
    private func weekDay(from date: Date) -> WeekDay {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        switch weekday {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        case 1: return .sunday
        default: return .monday
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension TrackersViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate categories: [TrackerCategory]) {
        self.categories = categories
        updateContentVisibility()
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewModel: TrackerStoreDelegate {
    func trackerStore(_ store: TrackerStore, didUpdate trackers: [Tracker]) {
        categories = categoryStore.categories
        updateContentVisibility()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStore(_ store: TrackerRecordStore, didUpdate records: [TrackerRecord]) {
        guard hasTrackersToDisplay else { return }
        onCollectionViewReloadData?()
    }
}
