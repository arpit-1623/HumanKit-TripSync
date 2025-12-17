//
//  SceneDelegate.swift
//  TripSync
//
//  Created by Arpit Garg on 14/11/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check authentication status
        if AuthService.shared.isAuthenticated() {
            // User is authenticated, determine which screen to show
            navigateBasedOnUserState()
        } else {
            // User is not authenticated, show splash/onboarding flow
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let navController = mainStoryboard.instantiateInitialViewController() {
                window?.rootViewController = navController
            }
        }
        
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Navigation Helpers
    
    /// Navigate to appropriate screen based on user state
    func navigateBasedOnUserState() {
        guard let currentUser = DataModel.shared.getCurrentUser() else {
            // No current user, fallback to login
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let navController = mainStoryboard.instantiateInitialViewController() {
                window?.rootViewController = navController
            }
            return
        }
        
        let userTrips = DataModel.shared.getUserAccessibleTrips(currentUser.id)
        let isFirstTime = AuthService.shared.isFirstTimeUser()
        
        // Navigation Logic:
        // 1. First-time user → Empty Home Screen in Tab Bar
        // 2. Returning user with NO trips → Empty Home Screen in Tab Bar
        // 3. User with trips → Main Tab Bar
        
        if isFirstTime || userTrips.isEmpty {
            navigateToEmptyHomeInTabBar()
        } else {
            navigateToMainApp()
        }
    }
    
    /// Navigate to main tab bar controller with all tabs
    func navigateToMainApp() {
        guard let window = window else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            window.rootViewController = tabBarController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    /// Navigate to empty home screen embedded in tab bar controller
    func navigateToEmptyHomeInTabBar() {
        guard let window = window else { return }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let emptyHomeStoryboard = UIStoryboard(name: "SD06_EmptyHomeScreen", bundle: nil)
        
        guard let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController,
              let emptyHomeNav = emptyHomeStoryboard.instantiateInitialViewController() else {
            return
        }
        
        // Replace the first tab (Home) with the empty home screen
        var viewControllers = tabBarController.viewControllers ?? []
        if !viewControllers.isEmpty {
            // Preserve the tab bar item from the original home tab
            let originalHomeTabBarItem = viewControllers[0].tabBarItem
            emptyHomeNav.tabBarItem = originalHomeTabBarItem
            viewControllers[0] = emptyHomeNav
            tabBarController.viewControllers = viewControllers
        }
        
        // Set Home tab as selected
        tabBarController.selectedIndex = 0
        
        window.rootViewController = tabBarController
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

