//
//  ScreenshotTests.swift
//  TrackerTests
//
//  Created by Anastasia Belyakova on 23.06.2026.
//

import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testViewController() throws {
        let viewModel = TrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)

        vc.loadViewIfNeeded()

        assertSnapshots(matching: vc, as: [.image])
    }
}
