//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 18.06.2026.
//

import Foundation

final class StatisticsViewModel {
    
    // MARK: - Bindings
    
    var onEmptyStateChanged: ((Bool) -> Void)?
    var onStatisticsUpdated: (() -> Void)?
    
    // MARK: - Properties
    
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    private(set) var items: [StatisticsItem] = []
    
    // MARK: - Initialization
    
    init(
        trackerStore: TrackerStore? = nil,
        recordStore: TrackerRecordStore? = nil
    ) {
        let store = trackerStore ?? TrackerStore()
        self.trackerStore = store
        self.recordStore = recordStore ?? TrackerRecordStore(trackerStore: store)
        
        self.trackerStore.delegate = self
        self.recordStore.delegate = self
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        updateStatistics()
    }
    
    // MARK: - Table View
    
    var numberOfItems: Int {
        items.count
    }
    
    func item(at index: Int) -> StatisticsItem? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }
    
    // MARK: - Private Methods
    
    private func updateStatistics() {
        let records = recordStore.records
        let isEmpty = records.isEmpty
        
        if isEmpty {
            items = []
        } else {
            let metrics = calculateMetrics(from: records)
            items = makeItems(from: metrics)
        }
        
        onEmptyStateChanged?(isEmpty)
        onStatisticsUpdated?()
    }
    
    private func calculateMetrics(from records: [TrackerRecord]) -> StatisticsMetrics {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysWithCompletions = Set(records.map { calendar.startOfDay(for: $0.date) })
        
        let numberOfCompletedTrackers = records.count
        let averageValue = daysWithCompletions.isEmpty
        ? 0
        : numberOfCompletedTrackers / daysWithCompletions.count
        
        guard let earliestDay = daysWithCompletions.min() else {
            return StatisticsMetrics(
                bestPeriod: 0,
                perfectDays: 0,
                numberOfCompletedTrackers: 0,
                averageValue: 0
            )
        }
        
        let perfectDays = countPerfectDays(from: earliestDay, to: today)
        let bestPeriod = calculateBestPeriod(from: daysWithCompletions.sorted())
        
        return StatisticsMetrics(
            bestPeriod: bestPeriod,
            perfectDays: perfectDays,
            numberOfCompletedTrackers: numberOfCompletedTrackers,
            averageValue: averageValue
        )
    }
    
    private func countPerfectDays(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        var perfectDays = 0
        
        while currentDate <= endDay {
            let scheduledTrackers = trackersScheduled(for: currentDate)
            
            if !scheduledTrackers.isEmpty,
               scheduledTrackers.allSatisfy({ recordStore.isTrackerCompleted(trackerId: $0.id, on: currentDate) }) {
                perfectDays += 1
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return perfectDays
    }
    
    private func calculateBestPeriod(from sortedDays: [Date]) -> Int {
        guard let firstDay = sortedDays.first else { return 0 }
        
        let calendar = Calendar.current
        var bestPeriod = 1
        var currentPeriod = 1
        var previousDay = firstDay
        
        for day in sortedDays.dropFirst() {
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDay),
               calendar.isDate(nextDay, inSameDayAs: day) {
                currentPeriod += 1
            } else {
                currentPeriod = 1
            }
            
            bestPeriod = max(bestPeriod, currentPeriod)
            previousDay = day
        }
        
        return bestPeriod
    }
    
    private func trackersScheduled(for date: Date) -> [Tracker] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)
        
        guard selectedDay <= today else { return [] }
        
        let weekDay = weekDay(from: date)
        return trackerStore.trackers.filter { $0.schedule.contains(weekDay) }
    }
    
    private func makeItems(from metrics: StatisticsMetrics) -> [StatisticsItem] {
        [
            StatisticsItem(
                title: "Лучший период",
                value: "\(metrics.bestPeriod)"
            ),
            StatisticsItem(
                title: "Идеальные дни",
                value: "\(metrics.perfectDays)"
            ),
            StatisticsItem(
                title: "Трекеров завершено",
                value: "\(metrics.numberOfCompletedTrackers)"
            ),
            StatisticsItem(
                title: "Среднее значение",
                value: "\(metrics.averageValue)"
            )
        ]
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

// MARK: - TrackerStoreDelegate

extension StatisticsViewModel: TrackerStoreDelegate {
    func trackerStore(_ store: TrackerStore, didUpdate trackers: [Tracker]) {
        updateStatistics()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension StatisticsViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStore(_ store: TrackerRecordStore, didUpdate records: [TrackerRecord]) {
        updateStatistics()
    }
}
