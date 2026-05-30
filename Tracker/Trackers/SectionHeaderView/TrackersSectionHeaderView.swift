//
//  TrackerSectionHeaderView.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 10.05.2026.
//

import UIKit

final class TrackerSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .blackDay
        return label
    }().forAutoLayout
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}

