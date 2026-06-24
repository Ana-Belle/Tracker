//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 26.05.2026.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ColorCell"
    
    private enum Layout {
        static let colorSize: CGFloat = 40
        static let selectionSize: CGFloat = 52
        static let colorCornerRadius: CGFloat = 8
        static let selectionCornerRadius: CGFloat = 16
        static let selectionOpacity: CGFloat = 0.3
    }
    
    private let selectionBorderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.selectionCornerRadius
        view.isHidden = true
        return view
    }().forAutoLayout
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.colorCornerRadius
        view.clipsToBounds = true
            //view.layer.borderColor = UIColor.whiteDayNight.cgColor
        //view.layer.borderWidth = 3
        return view
    }().forAutoLayout
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectionBorderView)
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            selectionBorderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionBorderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionBorderView.widthAnchor.constraint(equalToConstant: Layout.selectionSize),
            selectionBorderView.heightAnchor.constraint(equalToConstant: Layout.selectionSize),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: Layout.colorSize),
            colorView.heightAnchor.constraint(equalToConstant: Layout.colorSize)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionBorderView.isHidden = true
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        colorView.layer.borderWidth = isSelected ? 3 : 0
        //colorView.layer.borderColor = colors.borderColor.cgColor
        colorView.layer.borderColor = UIColor.whiteDayNight.cgColor
        selectionBorderView.backgroundColor = color.withAlphaComponent(Layout.selectionOpacity)
        selectionBorderView.isHidden = !isSelected
    }
}
