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
    
    // MARK: - Setup
    private func setupTableView() {
        membersTableView.delegate = self
        membersTableView.dataSource = self
        membersTableView.rowHeight = 88
        membersTableView.separatorStyle = .none
    }
    
    private func loadMembers() {
        // TODO: Load actual members from trip.memberIds
        // For now, using dummy data
        members = [
            User(fullName: "Aditya Singh", email: "aditya@example.com"),
            User(fullName: "Alice Johnson", email: "alice@example.com"),
            User(fullName: "Bob Smith", email: "bob@example.com"),
            User(fullName: "John Doe", email: "john@example.com")
        ]
        membersTableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addMemberTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Add Member",
            message: "Add member functionality will be implemented here",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
        
        // Determine role based on trip creator
        let role = indexPath.row == 0 ? "Admin" : "Member"
        
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "View Profile", style: .default) { [weak self] _ in
            self?.showMemberProfile(member)
        })
        
        // Show remove option for admin (except for first member)
        if indexPath.row != 0 {
            alert.addAction(UIAlertAction(title: "Remove Member", style: .destructive) { [weak self] _ in
                self?.removeMember(at: indexPath)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func removeMember(at indexPath: IndexPath) {
        let member = members[indexPath.row]
        
        let confirmAlert = UIAlertController(
            title: "Remove Member",
            message: "Are you sure you want to remove \(member.fullName) from this trip?",
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.members.remove(at: indexPath.row)
            self?.membersTableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        present(confirmAlert, animated: true)
    }
}
