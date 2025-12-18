//
//  CD07_EmptyTripsScreenVC.swift
//  TripSync
//
//  Created by Dikhsha Kumari on 11/12/25.
//

import UIKit

class EmptyTripsScreenViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var createTripButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if user now has trips (in case they came back from creating one)
        checkAndNavigateIfNeeded()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Hide back button if this is the root
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Navigation Check
    private func checkAndNavigateIfNeeded() {
        guard let currentUser = DataModel.shared.getCurrentUser() else { return }
        let userTrips = DataModel.shared.getUserAccessibleTrips(currentUser.id)
        
        // If user now has trips, navigate back to trips screen
        if !userTrips.isEmpty {
            navigateToTripsScreen()
        }
    }
    
    private func navigateToTripsScreen() {
        // Get the navigation controller and tab bar controller
        guard let navigationController = self.navigationController,
              let tabBarController = navigationController.tabBarController else {
            return
        }
        
        // Load the trips screen storyboard
        let tripsStoryboard = UIStoryboard(name: "SA01_Trips", bundle: nil)
        guard let tripsNav = tripsStoryboard.instantiateInitialViewController() else {
            return
        }
        
        // Find the index of the Trips tab
        if let viewControllers = tabBarController.viewControllers,
           let emptyTripsIndex = viewControllers.firstIndex(where: { ($0 as? UINavigationController)?.topViewController is EmptyTripsScreenViewController }) {
            
            // Preserve the tab bar item
            let originalTabBarItem = viewControllers[emptyTripsIndex].tabBarItem
            tripsNav.tabBarItem = originalTabBarItem
            
            // Replace with the regular trips screen
            var updatedViewControllers = viewControllers
            updatedViewControllers[emptyTripsIndex] = tripsNav
            tabBarController.viewControllers = updatedViewControllers
            
            // Set the selected index to the trips tab
            tabBarController.selectedIndex = emptyTripsIndex
        }
    }
    
    // MARK: - Actions
    @IBAction func createTripTapped(_ sender: UIButton) {
        // Segue will handle navigation to create trip flow
    }
    
    // MARK: - Unwind Segues
    @IBAction func unwindToEmptyTrips(_ segue: UIStoryboardSegue) {
        // User returned from create trip flow
        // Check if they now have trips and navigate accordingly
        checkAndNavigateIfNeeded()
    }
}
