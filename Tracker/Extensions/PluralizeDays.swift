//
//  PluralizeDays.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 24.06.2026.
//

import Foundation

func pluralizeDays(_ count: Int) -> String {
    let remainder10 = count % 10
    let remainder100 = count % 100
    
    if remainder10 == 1 && remainder100 != 11 {
        return "\(count) \(NSLocalizedString("day", comment: ""))"
    } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
        return "\(count) \(NSLocalizedString("days2", comment: ""))"
    } else {
        return "\(count) \(NSLocalizedString("days", comment: ""))"
    }
}
