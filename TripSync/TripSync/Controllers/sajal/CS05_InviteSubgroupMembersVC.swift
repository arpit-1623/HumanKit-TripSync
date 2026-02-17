//
//  CS05_InviteSubgroupMembersVC.swift
//  TripSync
//
//  Created by Sajal Garg on 24/11/25.
//

import UIKit

protocol InviteSubgroupMembersDelegate: AnyObject {
    func didUpdateMembers(_ memberIds: [UUID])
}

class CS05_InviteSubgroupMembersVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var membersTableView: UITableView!
    
    // MARK: - Properties
    weak var delegate: InviteSubgroupMembersDelegate?
    var trip: Trip?
    var subgroup: Subgroup?
    var allTripMembers: [User] = []
    private var selectedMemberIds: Set<UUID> = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMembers()
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSheetPresentation()
    }
    
    // MARK: - Setup
    private func loadMembers() {
        guard let trip = trip, let subgroup = subgroup else { return }
        
        // Get all pending invitations for this subgroup
        let allInvitations = DataModel.shared.getAllInvitations()
        let pendingInvitationUserIds = Set(allInvitations.filter {
            $0.type == .subgroup &&
            $0.status == .pending &&
            $0.subgroupId == subgroup.id
        }.map { $0.invitedUserId })
        
        // Load trip members who are not already in subgroup and don't have pending invitations
        allTripMembers = trip.memberIds.compactMap { memberId in
            DataModel.shared.getUser(byId: memberId)
        }.filter { user in
            !subgroup.memberIds.contains(user.id) && !pendingInvitationUserIds.contains(user.id)
        }
        
        // Start with no pre-selections (we're inviting, not adding)
        selectedMemberIds = []
    }
    
    private func setupNavigationBar() {
        title = "Invite"
        
        // Add button with count is managed programmatically since it's dynamic
        updateAddButton()
    }
    
    private func setupTableView() {
        membersTableView.delegate = self
        membersTableView.dataSource = self
        membersTableView.separatorStyle = .none
        membersTableView.backgroundColor = .systemGroupedBackground
    }
    
    private func updateAddButton() {
        let count = selectedMemberIds.count
        let title = count > 0 ? "Send (\(count))" : "Send"
        let addButton = UIBarButtonItem(
            title: title,
            style: .done,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.isEnabled = count > 0
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func configureSheetPresentation() {
        if let navController = navigationController {
            navController.modalPresentationStyle = .pageSheet
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @IBAction private func addButtonTapped() {
        sendInvitations()
    }
    
    private func sendInvitations() {
        guard let currentUser = DataModel.shared.getCurrentUser(),
              let subgroup = subgroup,
              let trip = trip else {
            showAlert(title: "Error", message: "Unable to send invitations")
            return
        }
        
        guard !selectedMemberIds.isEmpty else {
            showAlert(title: "No Members Selected", message: "Please select at least one member to invite")
            return
        }
        
        // Create invitation for each selected member
        for memberId in selectedMemberIds {
            let invitation = Invitation(
                type: .subgroup,
                tripId: trip.id,
                subgroupId: subgroup.id,
                invitedByUserId: currentUser.id,
                invitedUserId: memberId
            )
            DataModel.shared.saveInvitation(invitation)
        }
        
        // Show success message
        let memberCount = selectedMemberIds.count
        let message = memberCount == 1 ? "Invitation sent!" : "\(memberCount) invitations sent!"
        showAlert(title: "Success", message: message) {
            self.dismiss(animated: true)
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CS05_InviteSubgroupMembersVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTripMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as? MemberTableViewCell else {
            return UITableViewCell()
        }
        
        let member = allTripMembers[indexPath.row]
        let role = (trip?.createdByUserId == member.id) ? "Admin" : "Member"
        cell.configure(with: member, role: role)
        
        // Show checkmark if selected
        cell.accessoryType = selectedMemberIds.contains(member.id) ? .checkmark : .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CS05_InviteSubgroupMembersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let member = allTripMembers[indexPath.row]
        
        // Toggle selection
        if selectedMemberIds.contains(member.id) {
            selectedMemberIds.remove(member.id)
        } else {
            selectedMemberIds.insert(member.id)
        }
        
        // Update UI
        tableView.reloadRows(at: [indexPath], with: .automatic)
        updateAddButton()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}
