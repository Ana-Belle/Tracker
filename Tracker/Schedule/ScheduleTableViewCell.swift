//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 13.05.2026.
//

import UIKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func switchValueChanged(isOn: Bool, at index: Int)
}

final class ScheduleTableViewCell: UITableViewCell {
    static let identifier = "ScheduleTableViewCell"
    
    weak var delegate: ScheduleTableViewCellDelegate?
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        return label
    }().forAutoLayout
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .systemBlue
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return switchControl
    }().forAutoLayout
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupView() {
        selectionStyle = .none
        contentView.addSubview(dayLabel)
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(day: String, isEnabled: Bool, delegate: ScheduleTableViewCellDelegate) {
        dayLabel.text = day
        switchControl.isOn = isEnabled
        self.delegate = delegate
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        delegate?.switchValueChanged(isOn: sender.isOn, at: tag)
    }
}
