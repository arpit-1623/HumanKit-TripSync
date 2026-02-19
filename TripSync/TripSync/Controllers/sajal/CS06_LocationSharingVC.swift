//
//  CS06_LocationSharingVC.swift
//  TripSync
//
//  Created on 23/11/2025.
//

import UIKit

enum LocationSharingDuration: String, Codable, CaseIterable {
    case oneHour = "1 Hour"
    case threeHours = "3 Hours"
    case endOfDay = "Until End of Day"
    case twentyFourHours = "24 Hours"
    case indefinitely = "Indefinitely"
    
    var timeInterval: TimeInterval? {
        switch self {
        case .oneHour: return 3600
        case .threeHours: return 10800
        case .endOfDay:
            // Calculate seconds until end of current day
            let calendar = Calendar.current
            guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) else { return 86400 }
            return endOfDay.timeIntervalSinceNow
        case .twentyFourHours: return 86400
        case .indefinitely: return nil
        }
    }
}

class LocationSharingViewController: UITableViewController {
    
    // MARK: - Outlets (Static Cells)
    @IBOutlet weak var locationToggle: UISwitch!
    @IBOutlet weak var duration1HourCell: UITableViewCell!
    @IBOutlet weak var duration3HoursCell: UITableViewCell!
    @IBOutlet weak var durationEndOfDayCell: UITableViewCell!
    @IBOutlet weak var duration24HoursCell: UITableViewCell!
    @IBOutlet weak var durationIndefinitelyCell: UITableViewCell!
    
    // MARK: - Properties
    private var user: User?
    private var isLocationSharingEnabled: Bool = false
    private var selectedDuration: LocationSharingDuration = .oneHour
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Location Sharing"
        
        // Update selected duration
        updateSelectedDuration()
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        user = DataModel.shared.getCurrentUser()
        isLocationSharingEnabled = user?.userPreferences.shareLocation != .off
        locationToggle.isOn = isLocationSharingEnabled
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isLocationSharingEnabled ? 2 : 1
    }
    
    // MARK: - Helper Methods
    private func updateSelectedDuration() {
        let cells = [
            (duration1HourCell, LocationSharingDuration.oneHour),
            (duration3HoursCell, LocationSharingDuration.threeHours),
            (durationEndOfDayCell, LocationSharingDuration.endOfDay),
            (duration24HoursCell, LocationSharingDuration.twentyFourHours),
            (durationIndefinitelyCell, LocationSharingDuration.indefinitely)
        ]
        
        for (cell, duration) in cells {
            cell?.accessoryType = (duration == selectedDuration) ? .checkmark : .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Section 1: Duration options
        if indexPath.section == 1 {
            selectedDuration = LocationSharingDuration.allCases[indexPath.row]
            updateSelectedDuration()
            
            // Save selected duration and compute expiry
            guard var user = user else { return }
            user.userPreferences.locationSharingDuration = selectedDuration
            if let interval = selectedDuration.timeInterval {
                user.userPreferences.locationSharingExpiresAt = Date().addingTimeInterval(interval)
            } else {
                // Indefinitely — no expiry
                user.userPreferences.locationSharingExpiresAt = nil
            }
            DataModel.shared.saveUser(user)
            DataModel.shared.setCurrentUser(user)
            self.user = user
        }
    }
    
    // MARK: - Actions
    @IBAction private func toggleChanged(_ sender: UISwitch) {
        isLocationSharingEnabled = sender.isOn
        
        guard var user = user else { return }
        
        if isLocationSharingEnabled {
            user.userPreferences.shareLocation = .allTrips
            // Set default duration
            user.userPreferences.locationSharingDuration = selectedDuration
            if let interval = selectedDuration.timeInterval {
                user.userPreferences.locationSharingExpiresAt = Date().addingTimeInterval(interval)
            } else {
                user.userPreferences.locationSharingExpiresAt = nil
            }
        } else {
            user.userPreferences.shareLocation = .off
            // Clear duration and expiry
            user.userPreferences.locationSharingDuration = nil
            user.userPreferences.locationSharingExpiresAt = nil
        }
        
        DataModel.shared.saveUser(user)
        DataModel.shared.setCurrentUser(user)
        self.user = user
        
        // Update section visibility with animation
        if isLocationSharingEnabled {
            tableView.insertSections(IndexSet(integer: 1), with: .fade)
        } else {
            tableView.deleteSections(IndexSet(integer: 1), with: .fade)
        }
    }
}
