//
//  CA04_TripMembersVC.swift
//  TripSync
//
//  Created by Arpit Garg on 20/11/25.
//

import UIKit

class TripMembersViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var membersTableView: UITableView!
    
    // MARK: - Properties
    var trip: Trip?
    var members: [User] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadMembers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh trip and members data when returning
        if let tripId = trip?.id,
           let updatedTrip = DataModel.shared.getTrip(byId: tripId) {
            trip = updatedTrip
            loadMembers()
        }
    }
    
    // MARK: - Setup
    private func setupTableView() {
        membersTableView.delegate = self
        membersTableView.dataSource = self
        membersTableView.rowHeight = 88
        membersTableView.separatorStyle = .none
    }
    
    private func loadMembers() {
        guard let trip = trip else {
            members = []
            membersTableView.reloadData()
            return
        }
        
        // Load actual members from trip.memberIds
        members = trip.memberIds.compactMap { memberId in
            DataModel.shared.getUser(byId: memberId)
        }
        
        membersTableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TripMembersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as? MemberTableViewCell else {
            return UITableViewCell()
        }
        
        let member = members[indexPath.row]
        
        let role = (trip?.createdByUserId == member.id) ? "Admin" : "Member"
        
        cell.configure(with: member, role: role)
        cell.menuButtonTapped = { [weak self] in
            self?.showMemberMenu(for: member, at: indexPath)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TripMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let member = members[indexPath.row]
        showMemberProfile(member)
    }
    
    private func showMemberProfile(_ member: User) {
        let alert = UIAlertController(
            title: member.fullName,
            message: "Profile details will be shown here",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showMemberMenu(for member: User, at indexPath: IndexPath) {
        guard let currentUser = DataModel.shared.getCurrentUser(),
              let trip = trip else { return }
        
        let isCurrentUserAdmin = trip.isUserAdmin(currentUser.id)
        let isMemberAdmin = trip.isUserAdmin(member.id)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "View Profile", style: .default) { [weak self] _ in
            self?.showMemberProfile(member)
        })
        
        // Only show remove option if current user is admin and target is not admin
        if isCurrentUserAdmin && !isMemberAdmin {
            alert.addAction(UIAlertAction(title: "Remove Member", style: .destructive) { [weak self] _ in
                self?.removeMember(member, at: indexPath)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func removeMember(_ member: User, at indexPath: IndexPath) {
        let confirmAlert = UIAlertController(
            title: "Remove Member",
            message: "Are you sure you want to remove \(member.fullName) from this trip?",
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self = self,
                  let tripId = self.trip?.id else { return }
            
            if DataModel.shared.removeMemberFromTrip(tripId: tripId, memberId: member.id) {
                self.members.remove(at: indexPath.row)
                self.membersTableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "Unable to remove member. Please try again.",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            }
        })
        
        present(confirmAlert, animated: true)
    }
}
