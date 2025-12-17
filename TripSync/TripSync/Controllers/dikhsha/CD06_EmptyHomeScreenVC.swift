//
//  CD06_EmptyHomeScreenVC.swift
//  TripSync
//
//  Created by Dikhsha Kumari on 10/12/2025.
//

import UIKit

class EmptyHomeScreenViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var createTripButton: UIButton!
    @IBOutlet weak var joinTripButton: UIButton!
    
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
        
        // If user now has trips, navigate to main tab bar
        if !userTrips.isEmpty {
            navigateToMainTabBar()
        }
    }
    
    private func navigateToMainTabBar() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            return
        }
        
        // Use centralized navigation helper
        sceneDelegate.navigateToMainApp()
    }
    
    // MARK: - Actions
    @IBAction func createTripTapped(_ sender: UIButton) {
        // Segue will handle navigation to create trip flow
    }
    
    @IBAction func joinTripTapped(_ sender: UIButton) {
        // Segue will handle navigation to join trip flow
    }
    
    // MARK: - Unwind Segues
    @IBAction func unwindToEmptyHome(_ segue: UIStoryboardSegue) {
        // User returned from create/join trip flow
        // Check if they now have trips and navigate accordingly
        checkAndNavigateIfNeeded()
    }
}
