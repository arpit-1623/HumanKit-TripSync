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
    @IBOutlet weak var statCell: StatCell!
    @IBOutlet weak var privacyCell: PreferenceCell!
    @IBOutlet weak var locationCell: PreferenceCell!
    @IBOutlet weak var helpCell: ActionCell!
    @IBOutlet weak var aboutCell: ActionCell!
    @IBOutlet weak var logoutCell: ActionCell!
    
    // MARK: - Properties
    private var user: User?
    private var stats: (trips: Int, memories: Int, photos: Int) = (0, 0, 0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
        calculateStats()
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
    
    private func calculateStats() {
        guard let user = user else { return }
        
        // Get all trips for the user
        let userTrips = DataModel.shared.getAllTrips().filter { trip in
            trip.memberIds.contains(user.id)
        }
        stats.trips = userTrips.count
        
        // Get all memories for user's trips
        let tripIds = Set(userTrips.map { $0.id })
        let userMemories = DataModel.shared.getAllMemories().filter { memory in
            tripIds.contains(memory.tripId)
        }
        stats.memories = userMemories.count
        
        // Calculate total photos from memories
        stats.photos = userMemories.reduce(0) { $0 + $1.photoData.count }
    }
    
    // MARK: - Cell Configuration
    private func configureAllCells() {
        // Configure Profile Header
        if let user = user {
            profileHeaderCell.configure(with: user)
        }
        
        // Configure Stats
        statCell.configureHorizontal(trips: stats.trips, memories: stats.memories, photos: stats.photos)
        
        // Configure Privacy Cell
        let isPrivacyOn = user?.userPreferences.showApproximateLocation ?? false
        privacyCell.configure(title: "Privacy", icon: "lock.fill", hasToggle: true, isToggleOn: isPrivacyOn)
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
        
        // Section 0: Profile & Stats (not tappable)
        // Section 1: Preferences
        if indexPath.section == 1 {
            if indexPath.row == 1 {  // Location Sharing
                showLocationSharingOptions()
            }
        }
        // Section 2: Account
        else if indexPath.section == 2 {
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
    private func handlePrivacyToggle(isOn: Bool) {
        guard var user = user else { return }
        user.userPreferences.showApproximateLocation = isOn
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
        // Clear current user
        DataModel.shared.setCurrentUser(nil)
        
        // Show confirmation
        let alert = UIAlertController(
            title: "Logged Out",
            message: "You have been successfully logged out.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
