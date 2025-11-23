//
//  CS05_ProfileVC.swift
//  TripSync
//
//  Created on 23/11/2025.
//

import UIKit

class ProfileViewController: UITableViewController {
    
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
        
        // Reload only the preferences section to update location sharing status
        if tableView.numberOfSections > 1 {
            tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Profile"
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        // Cells are registered as prototypes in the storyboard
        // No need to register them programmatically
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
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2  // Profile Header + Stats (merged into one section)
        case 1: return 2  // Preferences (Privacy, Location Sharing)
        case 2: return 3  // Account (Help, About, Log Out)
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // First section contains both profile header and stats
            if indexPath.row == 0 {
                return configureProfileHeaderCell(at: indexPath)
            } else {
                return configureStatCell(at: indexPath)
            }
        case 1:
            return configurePreferenceCell(at: indexPath)
        case 2:
            return configureActionCell(at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - Cell Configuration
    private func configureProfileHeaderCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell", for: indexPath) as? ProfileHeaderCell else {
            return UITableViewCell()
        }
        
        if let user = user {
            cell.configure(with: user)
        }
        
        return cell
    }
    
    private func configureStatCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatCell", for: indexPath) as? StatCell else {
            return UITableViewCell()
        }
        
        // Configure cell with all three stats horizontally
        cell.configureHorizontal(trips: stats.trips, memories: stats.memories, photos: stats.photos)
        
        return cell
    }
    
    private func configurePreferenceCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceCell", for: indexPath) as? PreferenceCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            let isPrivacyOn = user?.userPreferences.showApproximateLocation ?? false
            cell.configure(title: "Privacy", icon: "lock.fill", hasToggle: true, isToggleOn: isPrivacyOn)
            cell.toggleChanged = { [weak self] isOn in
                self?.handlePrivacyToggle(isOn: isOn)
            }
        case 1:
            let locationMode = user?.userPreferences.shareLocation ?? .off
            let subtitle: String
            switch locationMode {
            case .off: subtitle = "Off"
            case .tripOnly: subtitle = "Current Trip Only"
            case .allTrips: subtitle = "All Trips"
            }
            cell.configure(title: "Location Sharing", icon: "location.fill", hasToggle: false, subtitle: subtitle)
        default:
            break
        }
        
        return cell
    }
    
    private func configureActionCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as? ActionCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cell.configure(title: "Help & Support", icon: "questionmark.circle.fill", isDestructive: false)
        case 1:
            cell.configure(title: "About TripSync", icon: "info.circle.fill", isDestructive: false)
        case 2:
            cell.configure(title: "Log Out", icon: "rectangle.portrait.and.arrow.right", isDestructive: true)
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return indexPath.row == 0 ? 100 : 120  // Profile Header : Stats
        default:
            return 60  // Preferences and Actions
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 32
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Preferences"
        case 2: return "Account"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 1:
            if indexPath.row == 1 {
                showLocationSharingOptions()
            }
        case 2:
            handleAccountAction(at: indexPath.row)
        default:
            break
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
        let storyboard = UIStoryboard(name: "SS06_LocationSharing", bundle: nil)
        if let locationSharingVC = storyboard.instantiateInitialViewController() {
            navigationController?.pushViewController(locationSharingVC, animated: true)
        }
    }
    
    private func handleAccountAction(at row: Int) {
        switch row {
        case 0:
            showHelpAndSupport()
        case 1:
            showAboutTripSync()
        case 2:
            showLogOutConfirmation()
        default:
            break
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
