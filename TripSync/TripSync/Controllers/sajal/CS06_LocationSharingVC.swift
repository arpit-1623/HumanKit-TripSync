//
//  CS06_LocationSharingVC.swift
//  TripSync
//
//  Created on 23/11/2025.
//

import UIKit

enum LocationSharingDuration: String, CaseIterable {
    case oneHour = "1 Hour"
    case threeHours = "3 Hours"
    case endOfDay = "Until End of Day"
    case twentyFourHours = "24 Hours"
    case indefinitely = "Indefinitely"
}

class LocationSharingViewController: UITableViewController {
    
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
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = true
        
        // Add back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        user = DataModel.shared.getCurrentUser()
        isLocationSharingEnabled = user?.userPreferences.shareLocation != .off
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2  // Share Location toggle + Description
        case 1: return isLocationSharingEnabled ? LocationSharingDuration.allCases.count : 0
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return configureToggleCell(at: indexPath)
            } else {
                return configureDescriptionCell(at: indexPath)
            }
        case 1:
            return configureDurationCell(at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - Cell Configuration
    private func configureToggleCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ToggleCell")
        cell.selectionStyle = .none
        cell.backgroundColor = .systemBackground
        
        // Icon
        let iconLabel = UILabel()
        if let image = UIImage(systemName: "location.fill") {
            let attachment = NSTextAttachment()
            attachment.image = image.withTintColor(.label, renderingMode: .alwaysOriginal)
            iconLabel.attributedText = NSAttributedString(attachment: attachment)
        }
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Share Location"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Switch
        let toggle = UISwitch()
        toggle.isOn = isLocationSharingEnabled
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(iconLabel)
        cell.contentView.addSubview(titleLabel)
        cell.contentView.addSubview(toggle)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            iconLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            toggle.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
            toggle.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
    
    private func configureDescriptionCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DescriptionCell")
        cell.selectionStyle = .none
        cell.backgroundColor = .systemBackground
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Your real-time location will be visible to trip members"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])
        
        return cell
    }
    
    private func configureDurationCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DurationCell")
        cell.backgroundColor = .systemBackground
        
        let duration = LocationSharingDuration.allCases[indexPath.row]
        cell.textLabel?.text = duration.rawValue
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cell.textLabel?.textColor = .label
        
        // Show checkmark for selected duration
        if duration == selectedDuration {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return UITableView.automaticDimension
        }
        return 56
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 40 : 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && isLocationSharingEnabled {
            return "SHARE FOR"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 1 ? 60 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 && isLocationSharingEnabled {
            let footerView = UIView()
            footerView.backgroundColor = .clear
            
            let footerLabel = UILabel()
            footerLabel.text = "Location sharing will automatically stop after the selected duration. You can stop sharing at any time."
            footerLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            footerLabel.textColor = .secondaryLabel
            footerLabel.numberOfLines = 0
            footerLabel.textAlignment = .center
            footerLabel.translatesAutoresizingMaskIntoConstraints = false
            
            footerView.addSubview(footerLabel)
            
            NSLayoutConstraint.activate([
                footerLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 8),
                footerLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
                footerLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
                footerLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -8)
            ])
            
            return footerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            selectedDuration = LocationSharingDuration.allCases[indexPath.row]
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    // MARK: - Actions
    @objc private func toggleChanged(_ sender: UISwitch) {
        isLocationSharingEnabled = sender.isOn
        
        guard var user = user else { return }
        
        if isLocationSharingEnabled {
            user.userPreferences.shareLocation = .allTrips
        } else {
            user.userPreferences.shareLocation = .off
        }
        
        DataModel.shared.saveUser(user)
        DataModel.shared.setCurrentUser(user)
        self.user = user
        
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
