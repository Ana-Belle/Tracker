//
//  UserDefaultsService.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 24.06.2026.
//

import UIKit

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    private enum Key {
        static let isOnboardingCompleted = "isOnboardingCompleted"
    }
    
    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Key.isOnboardingCompleted) }
        set { defaults.set(newValue, forKey: Key.isOnboardingCompleted) }
    }
}
