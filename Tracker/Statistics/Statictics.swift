//
//  Statictics.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 19.06.2026.
//

import Foundation

struct StatisticsItem {
    let title: String
    let value: String
}

struct StatisticsMetrics {
    let bestPeriod: Int
    let perfectDays: Int
    let numberOfCompletedTrackers: Int
    let averageValue: Int
}
