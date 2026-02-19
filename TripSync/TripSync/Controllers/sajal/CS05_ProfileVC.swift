//
//  CS05_ProfileVC.swift
//  TripSync
//
//  Created on 23/11/2025.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    // MARK: - Outlets (Static Cells)
    @IBOutlet weak var profileHeaderCell: ProfileHeaderCell!
    @IBOutlet weak var myTripsCell: MyTripsCell!
    @IBOutlet weak var privacyCell: PreferenceCell!
    @IBOutlet weak var locationCell: PreferenceCell!
    @IBOutlet weak var helpCell: ActionCell!
    @IBOutlet weak var aboutCell: ActionCell!
    @IBOutlet weak var logoutCell: ActionCell!
    
    // MARK: - Properties
    private var user: User?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
        configureAllCells()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Profile"
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        user = DataModel.shared.getCurrentUser()
    }
    
    // MARK: - Cell Configuration
    private func configureAllCells() {
        // Configure Profile Header
        if let user = user {
            profileHeaderCell.configure(with: user)
        }
        
        // Configure My Trips - show only trips created by the user
        if let user = user {
            let allUserTrips = DataModel.shared.getUserTrips(forUserId: user.id)
            let createdTrips = allUserTrips.filter { $0.createdByUserId == user.id }
            myTripsCell.configure(with: createdTrips)
            myTripsCell.onTripSelected = { [weak self] trip in
                self?.navigateToTripDetails(trip: trip)
            }
        }
        
        // Configure Privacy Cell
        let isPrivacyOn = user?.userPreferences.faceIdEnabled ?? false
        privacyCell.configure(title: "Face ID Unlock", icon: "faceid", hasToggle: true, isToggleOn: isPrivacyOn)
        privacyCell.toggleChanged = { [weak self] isOn in
            self?.handlePrivacyToggle(isOn: isOn)
        }
        
        // Configure Location Sharing Cell
        let locationMode = user?.userPreferences.shareLocation ?? .off
        let subtitle: String
        switch locationMode {
        case .off: subtitle = "Off"
        case .tripOnly: subtitle = "Current Trip Only"
        case .allTrips: subtitle = "All Trips"
        }
        locationCell.configure(title: "Location Sharing", icon: "location.fill", hasToggle: false, subtitle: subtitle)
        
        // Configure Action Cells
        helpCell.configure(title: "Help & Support", icon: "questionmark.circle.fill", isDestructive: false)
        aboutCell.configure(title: "About TripSync", icon: "info.circle.fill", isDestructive: false)
        logoutCell.configure(title: "Log Out", icon: "rectangle.portrait.and.arrow.right", isDestructive: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Section 0: Profile (tappable — navigate to Edit Profile)
        if indexPath.section == 0 {
            let storyboard = UIStoryboard(name: "SA08_EditProfile", bundle: nil)
            let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController")
            navigationController?.pushViewController(editProfileVC, animated: true)
        }
        // Section 1: My Trips (not tappable, handled by collection view)
        // Section 2: Preferences
        else if indexPath.section == 2 {
            if indexPath.row == 1 {  // Location Sharing
                showLocationSharingOptions()
            }
        }
        // Section 3: Account
        else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:  // Help & Support
                showHelpAndSupport()
            case 1:  // About TripSync
                showAboutTripSync()
            case 2:  // Log Out
                showLogOutConfirmation()
            default:
                break
            }
        }
    }
    
    // MARK: - Actions
    private func navigateToTripDetails(trip: Trip) {
        performSegue(withIdentifier: "profileToTripDetails", sender: trip)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToTripDetails",
           let tripDetailsVC = segue.destination as? TripDetailsViewController,
           let trip = sender as? Trip {
            tripDetailsVC.trip = trip
        }
    }
    
    private func handlePrivacyToggle(isOn: Bool) {
        guard var user = user else { return }
        user.userPreferences.faceIdEnabled = isOn
        DataModel.shared.saveUser(user)
        DataModel.shared.setCurrentUser(user)
        self.user = user
    }
    
    private func showLocationSharingOptions() {
        // Navigate to Location Sharing settings screen
        let storyboard = UIStoryboard(name: "SS07_LocationSharing", bundle: nil)
        if let locationSharingVC = storyboard.instantiateInitialViewController() {
            navigationController?.pushViewController(locationSharingVC, animated: true)
        }
    }
    
    private func showHelpAndSupport() {
        let alert = UIAlertController(
            title: "Help & Support",
            message: "Need assistance? Contact us at support@tripsync.com or visit our FAQ section in the app.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAboutTripSync() {
        let alert = UIAlertController(
            title: "About TripSync",
            message: "TripSync v1.0\n\nYour ultimate companion for group travel planning and coordination.\n\n© 2025 TripSync Team",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showLogOutConfirmation() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogOut()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogOut() {
        // Log out using AuthService (clears user and session)
        AuthService.shared.logout()
        
        // Navigate to splash/login screen
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let navController = mainStoryboard.instantiateInitialViewController() {
            window.rootViewController = navController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
