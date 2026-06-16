//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 17.06.2026.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    private let imageResource: ImageResource
    private let text: String
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: imageResource))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }().forAutoLayout
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }().forAutoLayout
    
    init(image: ImageResource, text: String) {
        self.imageResource = image
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
