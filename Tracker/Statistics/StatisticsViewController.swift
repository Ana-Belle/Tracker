//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 28.04.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
    private let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteDay
        titleLabel.text = "Статистика"
    }
}
