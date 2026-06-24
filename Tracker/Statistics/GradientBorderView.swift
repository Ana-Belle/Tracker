//
//  GradientBorderView.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 19.06.2026.
//

import UIKit

final class GradientBorderView: UIView {
    
    let contentView = UIView()
    
    private let gradientLayer = CAGradientLayer()
    
    var cornerRadius: CGFloat = 16 {
        didSet { setNeedsLayout() }
    }
    
    var borderWidth: CGFloat = 1 {
        didSet {
            topConstraint?.constant = borderWidth
            leadingConstraint?.constant = borderWidth
            trailingConstraint?.constant = -borderWidth
            bottomConstraint?.constant = -borderWidth
            setNeedsLayout()
        }
    }
    
    private var topConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    init(colors: [UIColor], locations: [NSNumber]? = nil) {
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations ?? [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
        
        contentView.backgroundColor = .whiteDayNight
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor, constant: borderWidth)
        leadingConstraint = contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: borderWidth)
        trailingConstraint = contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -borderWidth)
        bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -borderWidth)
        
        NSLayoutConstraint.activate([
            topConstraint,
            leadingConstraint,
            trailingConstraint,
            bottomConstraint
        ].compactMap { $0 })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius
        contentView.layer.cornerRadius = max(0, cornerRadius - borderWidth)
    }
}
