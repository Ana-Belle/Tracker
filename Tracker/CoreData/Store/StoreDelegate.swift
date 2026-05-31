//
//  StoreDelegate.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 31.05.2026.
//

import Foundation

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate categories: [TrackerCategory])
}

protocol TrackerStoreDelegate: AnyObject {
    func trackerStore(_ store: TrackerStore, didUpdate trackers: [Tracker])
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStore(_ store: TrackerRecordStore, didUpdate records: [TrackerRecord])
}
