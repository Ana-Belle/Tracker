//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 09.06.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private lazy var pages: [UIViewController] = [
        OnboardingPageViewController(
            image: .onboarding1,
            text: "Отслеживайте только\nто, что хотите"
        ),
        OnboardingPageViewController(
            image: .onboarding2,
            text: "Даже если это\nне литры воды и йога"
        )
    ]
    
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
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
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
