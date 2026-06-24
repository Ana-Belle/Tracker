//
//  TrackersViewControllerSnapshotTests.swift
//  TrackerTests
//
//  Created by Anastasia Belyakova on 23.06.2026.
//

import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    
    func testViewController() {
        let viewModel = TrackersViewModel()
        let vc = TrackersViewController(viewModel: viewModel)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.loadViewIfNeeded()
        
        assertSnapshots(of: vc, as: [
            "light": .image(traits: UITraitCollection(userInterfaceStyle: .light)),
            "dark": .image(traits: UITraitCollection(userInterfaceStyle: .dark))
        ])
        
    }
    
}
