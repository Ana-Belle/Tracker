//
//  AnalyticsModels.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 24.06.2026.
//

import Foundation

enum AnalyticsEvent: String {
    case click
    case open
    case close
}

enum AnalyticsKey: String {
    case screen
    case item
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case track
    case addTrack = "add_track"
    case filter
    case edit
    case delete
}

protocol AnalyticsParamConvertible {
    var analyticsString: String { get }
}

extension AnalyticsScreen: AnalyticsParamConvertible {
    var analyticsString: String { rawValue }
}

extension AnalyticsItem: AnalyticsParamConvertible {
    var analyticsString: String { rawValue }
}
