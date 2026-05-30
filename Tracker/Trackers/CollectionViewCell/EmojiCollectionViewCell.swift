//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 26.05.2026.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "EmojiCell"

    private enum Layout {
        static let selectionSize: CGFloat = 52
        static let cornerRadius: CGFloat = 16
    }

    private let selectionBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGray
        view.layer.cornerRadius = Layout.cornerRadius
        view.isHidden = true
        return view
    }().forAutoLayout

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }().forAutoLayout

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(emojiLabel)

        NSLayoutConstraint.activate([
            selectionBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: Layout.selectionSize),
            selectionBackgroundView.heightAnchor.constraint(equalToConstant: Layout.selectionSize),

            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectionBackgroundView.isHidden = true
    }

    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        selectionBackgroundView.isHidden = !isSelected
    }
}
