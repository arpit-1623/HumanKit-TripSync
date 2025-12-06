//
//  CS01_NotificationsVC.swift
//  TripSync
//
//  Created by GitHub Copilot on 06/12/25.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var emptyStateView: UIView?
    @IBOutlet weak var emptyStateImageView: UIImageView?
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    private var invitations: [Invitation] = []
    private var announcements: [Message] = []
    private var currentTrip: Trip?
    
    private enum NotificationTab: Int {
        case invites = 0
        case alerts = 1
    }
    
    private var currentTab: NotificationTab = .invites
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        segmentedControl?.selectedSegmentIndex = 0
        segmentedControl?.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        emptyStateImageView?.image = UIImage(systemName: "bell.slash")
        emptyStateImageView?.tintColor = .systemGray
        emptyStateLabel?.text = "No Invitations"
        emptyStateLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel?.textColor = .systemGray
    }
    
    private func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.register(SubgroupInviteCell.self, forCellReuseIdentifier: "SubgroupInviteCell")
        tableView?.register(AnnouncementCell.self, forCellReuseIdentifier: "AnnouncementCell")
    }
    
    private func loadData() {
        guard let currentUser = DataModel.shared.getCurrentUser() else { return }
        
        // Get current trip (assuming we're in trip context)
        let trips = DataModel.shared.getTrips(forUserId: currentUser.id)
        currentTrip = trips.first
        
        if currentTab == .invites {
            loadInvitations()
        } else {
            loadAnnouncements()
        }
    }
    
    private func loadInvitations() {
        guard let currentUser = DataModel.shared.getCurrentUser() else { return }
        
        // Get all pending subgroup invitations for current user
        let allInvitations = DataModel.shared.getAllInvitations()
        invitations = allInvitations.filter {
            $0.type == .subgroup &&
            $0.status == .pending &&
            $0.invitedUserId == currentUser.id
        }
        
        updateEmptyState()
        tableView?.reloadData()
    }
    
    private func loadAnnouncements() {
        guard let trip = currentTrip else {
            announcements = []
            updateEmptyState()
            tableView?.reloadData()
            return
        }
        
        // Load all announcements for the current trip
        let allMessages = DataModel.shared.getMessages(forTripId: trip.id, subgroupId: nil)
        announcements = allMessages.filter { $0.isAnnouncement }
        
        updateEmptyState()
        tableView?.reloadData()
    }
    
    private func updateEmptyState() {
        let isEmpty = currentTab == .invites ? invitations.isEmpty : announcements.isEmpty
        emptyStateView?.isHidden = !isEmpty
        tableView?.isHidden = isEmpty
        
        if currentTab == .invites {
            emptyStateLabel?.text = "No Invitations"
            emptyStateImageView?.image = UIImage(systemName: "person.2.slash")
        } else {
            emptyStateLabel?.text = "No Announcements"
            emptyStateImageView?.image = UIImage(systemName: "megaphone.slash")
        }
    }
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        currentTab = NotificationTab(rawValue: segmentedControl?.selectedSegmentIndex ?? 0) ?? .invites
        loadData()
    }
    
    @IBAction func cancelTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Invitation Actions
    private func acceptInvitation(_ invitation: Invitation) {
        guard let subgroupId = invitation.subgroupId,
              let subgroup = DataModel.shared.getSubgroup(byId: subgroupId),
              let currentUser = DataModel.shared.getCurrentUser() else {
            showAlert(title: "Error", message: "Unable to accept invitation")
            return
        }
        
        // Add user to subgroup
        var updatedSubgroup = subgroup
        if !updatedSubgroup.memberIds.contains(currentUser.id) {
            updatedSubgroup.memberIds.append(currentUser.id)
            DataModel.shared.saveSubgroup(updatedSubgroup)
        }
        
        // Update invitation status
        var updatedInvitation = invitation
        updatedInvitation.status = .accepted
        DataModel.shared.updateInvitation(updatedInvitation)
        
        // Reload data
        loadInvitations()
        
        showAlert(title: "Success", message: "You've joined \(subgroup.name)!")
    }
    
    private func declineInvitation(_ invitation: Invitation) {
        var updatedInvitation = invitation
        updatedInvitation.status = .declined
        DataModel.shared.updateInvitation(updatedInvitation)
        
        loadInvitations()
    }
    
    private func viewSubgroupDetails(_ invitation: Invitation) {
        guard let subgroupId = invitation.subgroupId,
              let subgroup = DataModel.shared.getSubgroup(byId: subgroupId) else {
            showAlert(title: "Error", message: "Unable to load subgroup details")
            return
        }
        
        // TODO: Navigate to subgroup details
        showAlert(title: subgroup.name, message: subgroup.description ?? "No description available")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTab == .invites ? invitations.count : announcements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentTab == .invites {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubgroupInviteCell", for: indexPath) as? SubgroupInviteCell ?? SubgroupInviteCell(style: .default, reuseIdentifier: "SubgroupInviteCell")
            
            let invitation = invitations[indexPath.row]
            cell.configure(with: invitation, onAccept: { [weak self] in
                self?.acceptInvitation(invitation)
            }, onDecline: { [weak self] in
                self?.declineInvitation(invitation)
            }, onViewDetails: { [weak self] in
                self?.viewSubgroupDetails(invitation)
            })
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementCell", for: indexPath) as? AnnouncementCell else {
                return UITableViewCell()
            }
            
            let announcement = announcements[indexPath.row]
            cell.configure(with: announcement)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if currentTab == .alerts {
            // Navigate to alerts section
            dismiss(animated: true) {
                // TODO: Post notification to switch to alerts tab
                NotificationCenter.default.post(name: NSNotification.Name("ShowAlertsSection"), object: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return currentTab == .invites ? 450 : 120
    }
}
