//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 28.04.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        
        let userDefaults = UserDefaultsService.shared
        let isOnboardingCompleted = userDefaults.isOnboardingCompleted
        window?.rootViewController = isOnboardingCompleted ? TabBarController() : OnboardingViewController()
        window?.makeKeyAndVisible()
    }
    
}

