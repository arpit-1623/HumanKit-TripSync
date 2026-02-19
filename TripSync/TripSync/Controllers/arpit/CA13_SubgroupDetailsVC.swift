//
//  CS03_SubgroupDetailsVC.swift
//  TripSync
//
//  Created by Arpit Garg on 23/11/2025.
//

import UIKit

class SubgroupDetailsViewController: UIViewController, SubgroupFormDelegate, InviteSubgroupMembersDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var itineraryButton: UIView!
    @IBOutlet weak var chatButton: UIView!
    @IBOutlet weak var membersTableView: UITableView!
    
    // MARK: - Properties
    var subgroup: Subgroup?
    var trip: Trip?
    var members: [User] = []
    private var invitationsByUserId: [UUID: Invitation] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadData()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh subgroup and trip data when returning
        if let subgroupId = subgroup?.id,
           let updatedSubgroup = DataModel.shared.getSubgroup(byId: subgroupId) {
            subgroup = updatedSubgroup
        }
        
        if let tripId = trip?.id,
           let updatedTrip = DataModel.shared.getTrip(byId: tripId) {
            trip = updatedTrip
        }
        
        loadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Circle Details"
        
        // Configure logo view
        logoView.layer.cornerRadius = 30
        logoView.layer.masksToBounds = true
        
        // Configure logo label
        logoLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        logoLabel.textColor = .white
        logoLabel.textAlignment = .center
        
        // Configure name label
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .label
        
        // Configure description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
    }
    
    private func setupTableView() {
        membersTableView.delegate = self
        membersTableView.dataSource = self
        membersTableView.isScrollEnabled = false
        membersTableView.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0)
    }
    
    private func loadData() {
        guard let subgroup = subgroup else { return }
        
        // Set subgroup details
        nameLabel.text = subgroup.name
        descriptionLabel.text = subgroup.description
        
        // Set logo color
        if let color = UIColor(hex: subgroup.colorHex) {
            logoView.backgroundColor = color
        } else {
            logoView.backgroundColor = .systemBlue
        }
        
        // Set logo initial (first letter of name)
        if let firstLetter = subgroup.name.first {
            logoLabel.text = String(firstLetter).uppercased()
        }
        
        // Load members from subgroup
        members = subgroup.memberIds.compactMap { memberId in
            DataModel.shared.getUser(byId: memberId)
        }
        
        // Load and cache accepted invitations for this subgroup
        // Use uniquingKeysWith to handle duplicate invitations (keep most recent)
        let acceptedInvitations = DataModel.shared.getInvitations(forSubgroupId: subgroup.id, status: .accepted)
        invitationsByUserId = Dictionary(acceptedInvitations.map { ($0.invitedUserId, $0) }, 
                                        uniquingKeysWith: { invitation1, invitation2 in
                                            invitation1.createdAt > invitation2.createdAt ? invitation1 : invitation2
                                        })
        
        membersTableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction private func editButtonTapped() {
        performSegue(withIdentifier: "subgroupDetailsToEdit", sender: subgroup)
    }
    
    @IBAction func itineraryButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let subgroup = subgroup else { return }
        
        // Navigate to itinerary with subgroup filter
        performSegue(withIdentifier: "subgroupDetailsToItinerary", sender: subgroup)
    }
    
    @IBAction func chatButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let subgroup = subgroup else { return }
        
        // Navigate to chat with subgroup filter
        performSegue(withIdentifier: "subgroupDetailsToChat", sender: subgroup)
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        // Navigate to invite members modal
        let storyboard = UIStoryboard(name: "SS05_InviteSubgroupMembers", bundle: nil)
        guard let navController = storyboard.instantiateInitialViewController() as? UINavigationController,
              let inviteVC = navController.topViewController as? CS05_InviteSubgroupMembersVC else {
            return
        }
        
        inviteVC.trip = trip
        inviteVC.subgroup = subgroup
        inviteVC.delegate = self
        
        present(navController, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subgroupDetailsToItinerary",
           let itineraryVC = segue.destination as? CS02_ItineraryVC,
           let subgroup = sender as? Subgroup {
            itineraryVC.trip = trip
            itineraryVC.selectedSubgroupId = subgroup.id
        } else if segue.identifier == "subgroupDetailsToChat",
                  let chatVC = segue.destination as? SubgroupChatViewController,
                  let subgroup = sender as? Subgroup {
            chatVC.trip = trip
            chatVC.subgroup = subgroup
        } else if segue.identifier == "subgroupDetailsToEdit",
                  let navController = segue.destination as? UINavigationController,
                  let formVC = navController.topViewController as? CS04_SubgroupFormVC,
                  let subgroup = sender as? Subgroup {
            formVC.existingSubgroup = subgroup
            formVC.trip = trip
            formVC.tripId = trip?.id
            formVC.delegate = self
        }
    }
    
    // MARK: - SubgroupFormDelegate
    func didCreateSubgroup(_ subgroup: Subgroup) {
        // Not used in details screen
    }
    
    func didUpdateSubgroup(_ subgroup: Subgroup) {
        // Update local subgroup
        self.subgroup = subgroup
        
        // Update DataModel (saveSubgroup handles both create and update)
        DataModel.shared.saveSubgroup(subgroup)
        
        // Reload UI
        loadData()
    }
    
    // MARK: - InviteSubgroupMembersDelegate
    func didUpdateMembers(_ memberIds: [UUID]) {
        // Note: This delegate method is no longer used since we switched to invitation-based flow
        // Invitations are sent instead of directly adding members
        // Keeping this for backward compatibility, but it won't be called from the new invite flow
        
        // Simply reload the UI in case anything changed
        loadData()
    }
}

// MARK: - UITableViewDataSource
extension SubgroupDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as? MemberTableViewCell else {
            return UITableViewCell()
        }
        
        let member = members[indexPath.row]
        
        // Determine role based on who created the subgroup
        let role: String
        if subgroup?.createdByUserId == member.id {
            role = "Admin"
        } else {
            role = ""
        }
        
        cell.configure(with: member, role: role)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SubgroupDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Only the subgroup creator (admin) can remove members
        guard let currentUser = DataModel.shared.getCurrentUser(),
              let subgroup = subgroup else { return false }
        return subgroup.createdByUserId == currentUser.id
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard var subgroup = subgroup else { return }
            
            let member = members[indexPath.row]
            
            // Don't allow removing the admin
            if subgroup.createdByUserId == member.id {
                let alert = UIAlertController(title: "Cannot Remove", message: "The circle admin cannot be removed.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            
            // Show confirmation dialog
            let confirmAlert = UIAlertController(
                title: "Remove Member",
                message: "Are you sure you want to remove \(member.fullName) from this circle?",
                preferredStyle: .alert
            )
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            confirmAlert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                // Remove member from subgroup
                subgroup.memberIds.removeAll { $0 == member.id }
                subgroup.updatedAt = Date()
                
                // Update DataModel
                DataModel.shared.saveSubgroup(subgroup)
                
                // Update local reference
                self.subgroup = subgroup
                
                // Find current index of the member (may have changed)
                if let currentIndex = self.members.firstIndex(where: { $0.id == member.id }) {
                    self.members.remove(at: currentIndex)
                    tableView.deleteRows(at: [IndexPath(row: currentIndex, section: 0)], with: .automatic)
                }
            })
            
            present(confirmAlert, animated: true)
        }
    }
}

