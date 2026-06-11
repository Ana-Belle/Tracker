//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 09.06.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private lazy var pages: [UIViewController] = {
        let pageView1 = UIViewController()
        let backgroundView1 = getBackgroundView(imageResource: .onboarding1)
        let label1 = getLabel(text: "Отслеживайте только то, что хотите")
        
        let pageView2 = UIViewController()
        let backgroundView2 = getBackgroundView(imageResource: .onboarding2)
        let label2 = getLabel(text: "Даже если это не литры воды и йога")
        
        pageView1.view.addSubview(backgroundView1)
        pageView1.view.addSubview(label1)
        
        pageView2.view.addSubview(backgroundView2)
        pageView2.view.addSubview(label2)
        
        NSLayoutConstraint.activate([
            label1.centerXAnchor.constraint(equalTo: pageView1.view.centerXAnchor),
            label1.topAnchor.constraint(equalTo: pageView1.view.topAnchor, constant: 432),
            label1.leadingAnchor.constraint(equalTo: pageView1.view.leadingAnchor, constant: 16),
            label1.trailingAnchor.constraint(equalTo: pageView1.view.trailingAnchor, constant: -16),
            
            label2.centerXAnchor.constraint(equalTo: pageView2.view.centerXAnchor),
            label2.topAnchor.constraint(equalTo: pageView2.view.topAnchor, constant: 432),
            label2.leadingAnchor.constraint(equalTo: pageView2.view.leadingAnchor, constant: 16),
            label2.trailingAnchor.constraint(equalTo: pageView2.view.trailingAnchor, constant: -16)
        ])
        
        return [pageView1, pageView2]
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.buttonTapped()
        })
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.whiteDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        return button
    }().forAutoLayout
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
            .forAutoLayout
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .blackDay
        pageControl.pageIndicatorTintColor = .blackDay.withAlphaComponent(0.3)
        
        return pageControl
    }()
    
    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [
                .interPageSpacing: 0
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: false, completion: nil)
        }
        
        view.addSubview(button)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func getBackgroundView(imageResource: ImageResource) -> UIImageView {
        let backgroundImage = UIImage(resource: imageResource)
        let backgroundView = UIImageView(image: backgroundImage)
        backgroundView.frame = view.bounds
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.contentMode = .scaleAspectFit
        return backgroundView
    }
    
    private func getLabel(text: String) -> UILabel {
        let label = UILabel()
            .forAutoLayout
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        
        return pages[nextIndex]
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
    
    @objc private func buttonTapped() {
        UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
        
        guard let window = view.window else { return }
        
        let tabBarController = TabBarController()
        UIView.transition(with: window, duration: 0.0, options: .transitionCrossDissolve) {
            window.rootViewController = tabBarController
        }
    }
}
