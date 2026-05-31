//
//  StoreError.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 27.05.2026.
//

import Foundation

enum StoreError: Error {
    case categoryNotFound
    case trackerNotFound
    case saveFailed(Error)
}
