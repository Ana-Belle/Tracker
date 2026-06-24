//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 22.06.2026.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "1ca56082-c34a-45aa-86c7-a8faf5832061") else { return }
        
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
