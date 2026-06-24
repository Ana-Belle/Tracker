//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 22.06.2026.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    static let shared = AnalyticsService()

    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: Constants.apiKey) else { return }

        AppMetrica.activate(with: configuration)
    }

    func report(event: AnalyticsEvent, params: [AnalyticsKey: any AnalyticsParamConvertible] = [:]) {
        let parameters = Dictionary(uniqueKeysWithValues: params.map { ($0.key.rawValue, $0.value.analyticsString) })
        report(event: event.rawValue, parameters: parameters)
    }

    private func report(event: String, parameters: [AnyHashable: Any]) {
        AppMetrica.reportEvent(name: event, parameters: parameters, onFailure: { error in
            TrackerLogger.shared.error("REPORT ERROR: %@ \(error.localizedDescription)")
        })
    }
}
