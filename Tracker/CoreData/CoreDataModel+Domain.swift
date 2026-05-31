//
//  CoreDataModel+Domain.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 27.05.2026.
//

import CoreData
import UIKit

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

extension TrackerCategoryCoreData {
    
    func toDomain() -> TrackerCategory {
        let domainTrackers = (trackers as? Set<TrackerCoreData> ?? [])
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
            .map { $0.toDomain() }
        
        return TrackerCategory(header: header ?? "", trackers: domainTrackers)
    }
}

extension TrackerRecordCoreData {
    
    func toDomain() -> TrackerRecord? {
        guard let trackerId = tracker?.id, let date else { return nil }
        return TrackerRecord(id: trackerId, date: date)
    }
}
