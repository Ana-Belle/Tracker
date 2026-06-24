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
    
    var onContentVisibilityChanged: ((_ hasTrackersToDisplay: Bool, _ showFiltersButton: Bool) -> Void)?
    var onCollectionViewReloadData: (() -> Void)?
    var onCollectionViewReloadItems: ((IndexPath) -> Void)?
    var onPresentNewTracker: (() -> Void)?
    var onPresentEditTracker: ((Tracker, String) -> Void)?
    var onShowDeleteConfirmation: ((UUID) -> Void)?
    var onLogInfo: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onPresentFilters: (() -> Void)?
    var onSelectedDateUpdated: ((Date) -> Void)?
    
    // MARK: - Properties
    
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    private let analyticsService = AnalyticsService()
    
    private var categories: [TrackerCategory] = []
    private(set) var selectedDate = Date()
    private(set) var selectedFilter: Filters = .allTrackers
    private var searchText = ""
    
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
                guard tracker.schedule.contains(weekDay) else { return false }
                guard matchesSearchQuery(tracker) else { return false }
                return matchesSelectedFilter(tracker)
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
    
    private var hasTrackersForSelectedDate: Bool {
        let weekDay = weekDay(from: selectedDate)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: selectedDate)
        
        guard selectedDay <= today else { return false }
        
        return categories.contains { category in
            category.trackers.contains { $0.schedule.contains(weekDay) }
        }
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
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "add_track"])
        onPresentNewTracker?()
    }
    
    func dateChanged(_ date: Date) {
        selectedDate = date
        
        if selectedFilter == .trackersForToday {
            selectedFilter = .allTrackers
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        onLogInfo?("Выбранная дата: \(dateFormatter.string(from: date))")
        
        updateContentVisibility()
    }
    
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        do {
            try recordStore.addRecord(trackerId: id, date: selectedDate)
            reloadAfterCompletionChange(at: indexPath)
        } catch {
            onError?("Не удалось сохранить выполнение трекера: \(error)")
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        do {
            try recordStore.deleteRecord(trackerId: id, date: selectedDate)
            reloadAfterCompletionChange(at: indexPath)
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
    
    func editTracker(at indexPath: IndexPath) {
        guard
            let cellViewModel = cellViewModel(at: indexPath),
            let categoryHeader = categoryHeader(for: cellViewModel.tracker.id)
        else {
            return
        }
        
        onPresentEditTracker?(cellViewModel.tracker, categoryHeader)
    }
    
    func requestDeleteTracker(id: UUID) {
        onShowDeleteConfirmation?(id)
    }
    
    func deleteTracker(id: UUID) {
        do {
            try trackerStore.deleteTracker(id: id)
        } catch {
            onError?("Не удалось удалить трекер: \(error)")
        }
    }
    
    func updateTracker(tracker: Tracker, categoryHeader: String, previousCategoryHeader: String) {
        do {
            try categoryStore.addCategory(header: categoryHeader)
            try trackerStore.updateTracker(tracker, toCategoryHeader: categoryHeader)
        } catch {
            onError?("Не удалось обновить трекер: \(error)")
        }
    }
    
    func filtersButtonTapped() {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "filter"])
        onPresentFilters?()
    }
    
    func selectFilter(_ filter: Filters) {
        selectedFilter = filter
        
        if filter == .trackersForToday {
            selectedDate = Date()
            onSelectedDateUpdated?(selectedDate)
        }
        
        updateContentVisibility()
    }
    
    func searchTextChanged(_ text: String) {
        searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        updateContentVisibility()
    }
    
    // MARK: - Private Methods
    
    private func matchesSearchQuery(_ tracker: Tracker) -> Bool {
        guard !searchText.isEmpty else { return true }
        return tracker.name.localizedCaseInsensitiveContains(searchText)
    }
    
    private func matchesSelectedFilter(_ tracker: Tracker) -> Bool {
        switch selectedFilter {
        case .allTrackers, .trackersForToday:
            return true
        case .completed:
            return recordStore.isTrackerCompleted(trackerId: tracker.id, on: selectedDate)
        case .notCompleted:
            return !recordStore.isTrackerCompleted(trackerId: tracker.id, on: selectedDate)
        }
    }
    
    private func reloadAfterCompletionChange(at indexPath: IndexPath) {
        if selectedFilter == .completed || selectedFilter == .notCompleted {
            updateContentVisibility()
        } else {
            onCollectionViewReloadItems?(indexPath)
        }
    }
    
    private func categoryHeader(for trackerId: UUID) -> String? {
        categories.first { category in
            category.trackers.contains { $0.id == trackerId }
        }?.header
    }
    
    private func updateContentVisibility() {
        onContentVisibilityChanged?(hasTrackersToDisplay, hasTrackersForSelectedDate)
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
        updateContentVisibility()
    }
}
