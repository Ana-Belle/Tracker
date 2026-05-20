//
//  TabBarController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 28.04.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTabBar()
    }
    
    private func configTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.tintColor = .ypBlue
        
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackers),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .stats),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
    
}

