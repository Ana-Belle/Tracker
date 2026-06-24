//
//  StatisticsTableViewCell.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 19.06.2026.
//

import UIKit

final class StatisticsTableViewCell: UITableViewCell {
    static let identifier = "StatisticsTableViewCell"
    
    private lazy var cardView = GradientBorderView(
        colors: [
            UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1),
            UIColor(red: 70 / 255, green: 230 / 255, blue: 157 / 255, alpha: 1),
            UIColor(red: 0 / 255, green: 123 / 255, blue: 250 / 255, alpha: 1)
        ],
        locations: [0.0, 0.5, 1.0]
    ).forAutoLayout
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackDayNight
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }().forAutoLayout
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackDayNight
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }().forAutoLayout
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(with item: StatisticsItem) {
        valueLabel.text = item.value
        titleLabel.text = item.title
    }
    
    private func setupView() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.contentView.addSubview(valueLabel)
        cardView.contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            valueLabel.topAnchor.constraint(equalTo: cardView.contentView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor, constant: -12)
        ])
    }
}
