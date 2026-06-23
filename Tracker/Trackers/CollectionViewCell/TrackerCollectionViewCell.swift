//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 08.05.2026.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
    func editTracker(id: UUID, at indexPath: IndexPath)
    func requestDeleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    private let analyticsService = AnalyticsService()

    private var tracker: Tracker?

    private lazy var trackerBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(resource: .border).cgColor
        return view
    }().forAutoLayout
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        label.font = .systemFont(ofSize: 16)
        label.backgroundColor = .emojiBackground
        label.layer.cornerRadius = label.frame.width / 2
        label.clipsToBounds = true
        return label
    }().forAutoLayout
    
    private lazy var trackerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }().forAutoLayout
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }().forAutoLayout
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus")
        button.setImage(image, for: .normal)
        button.tintColor = .ypWhite
        button.backgroundColor = .colorSelection5
        button.layer.cornerRadius = 34/2
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        button.isEnabled = true
        return button
    }().forAutoLayout
    
    weak var delegate: TrackerCellDelegate?
    
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupContextMenu()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupView() {
        contentView.addSubview(trackerBackgroundView)
        trackerBackgroundView.addSubview(emojiLabel)
        trackerBackgroundView.addSubview(trackerNameLabel)
        contentView.addSubview(daysCountLabel)
        contentView.isUserInteractionEnabled = true
        trackerBackgroundView.isUserInteractionEnabled = true
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            trackerBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            trackerBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerBackgroundView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: trackerBackgroundView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerBackgroundView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            trackerNameLabel.leadingAnchor.constraint(equalTo: trackerBackgroundView.leadingAnchor, constant: 12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: trackerBackgroundView.bottomAnchor, constant: -12),
            
            plusButton.topAnchor.constraint(equalTo: trackerBackgroundView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: trackerBackgroundView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: trackerBackgroundView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
        ])
        
        contentView.bringSubviewToFront(plusButton)
    }

    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        trackerBackgroundView.addInteraction(interaction)
    }
    
    func configure(with tracker: Tracker, isCompletedToday: Bool, completedDays: Int, indexPath: IndexPath) {
        self.tracker = tracker
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        trackerBackgroundView.backgroundColor = tracker.color
        
        emojiLabel.text = tracker.emoji
        trackerNameLabel.text = tracker.name
        
        let wordDay = pluralizeDays(completedDays)
        daysCountLabel.text = wordDay
        
        let image = isCompletedToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        plusButton.setImage(image, for: .normal)
        plusButton.backgroundColor = tracker.color
        plusButton.alpha = isCompletedToday ? 0.3 : 1
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if  remainder10 == 1 && remainder100 != 11 {
            return "\(count) \(NSLocalizedString("day", comment: ""))"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(count) \(NSLocalizedString("days2", comment: ""))"
        } else {
            return "\(count) \(NSLocalizedString("days", comment: ""))"
        }
    }
    
    @objc private func plusButtonTapped() {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "track"])

        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("no trackerId")
            return
        }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let trackerId = trackerId, let indexPath = indexPath else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                self?.analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "edit"])
                self?.delegate?.editTracker(id: trackerId, at: indexPath)
            }

            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self?.analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "delete"])
                self?.delegate?.requestDeleteTracker(id: trackerId, at: indexPath)
            }

            return UIMenu(children: [editAction, deleteAction])
        }
    }
}
