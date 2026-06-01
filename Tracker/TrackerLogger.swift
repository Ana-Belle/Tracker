//
//  TrackerLogger.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 01.06.2026.
//

import Logging

final class TrackerLogger {
    static let shared = TrackerLogger()

    private let logger = Logger(label: "")
    
    private init() {
    }

    func info(_ message: String) {
        logger.info(Logger.Message(stringLiteral: message))
    }

    func error(_ message: String) {
        logger.error(Logger.Message(stringLiteral: message))
    }
}
