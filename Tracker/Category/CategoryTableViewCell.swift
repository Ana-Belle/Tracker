//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 11.06.2026.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let identifier = "CategoryTableViewCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .blackDayNight
        return label
    }().forAutoLayout
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: SystemImage.checkmark.image)
        imageView.tintColor = .ypBlue
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(header: String, isSelected: Bool) {
        titleLabel.text = header
        checkmarkImageView.isHidden = !isSelected
    }
}
