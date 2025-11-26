//
//  CS03_SubgroupDetailsVC.swift
//  TripSync
//
//  Created on 23/11/2025.
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadData()
        setupTableView()
        setupGestureRecognizers()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Subgroup Details"
        
        // Add edit button to navigation bar
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = editButton
        
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
    
    private func setupGestureRecognizers() {
        // Add tap gesture to itinerary button
        let itineraryTap = UITapGestureRecognizer(target: self, action: #selector(itineraryButtonTapped(_:)))
        itineraryButton.addGestureRecognizer(itineraryTap)
        itineraryButton.isUserInteractionEnabled = true
        
        // Add tap gesture to chat button
        let chatTap = UITapGestureRecognizer(target: self, action: #selector(chatButtonTapped(_:)))
        chatButton.addGestureRecognizer(chatTap)
        chatButton.isUserInteractionEnabled = true
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
        
        membersTableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func editButtonTapped() {
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
        // Navigate to invite members modal via segue
        performSegue(withIdentifier: "showInviteMembers", sender: subgroup)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subgroupDetailsToItinerary",
           let itineraryVC = segue.destination as? CS02_ItineraryVC,
           let subgroup = sender as? Subgroup {
            itineraryVC.trip = trip
            itineraryVC.selectedSubgroupId = subgroup.id
        } else if segue.identifier == "subgroupDetailsToChat",
                  let chatVC = segue.destination as? GeneralChatViewController,
                  let subgroup = sender as? Subgroup {
            chatVC.trip = trip
            // TODO: Add subgroup filter property to chat when implemented
        } else if segue.identifier == "subgroupDetailsToEdit",
                  let navController = segue.destination as? UINavigationController,
                  let formVC = navController.topViewController as? CS04_SubgroupFormVC,
                  let subgroup = sender as? Subgroup {
            formVC.existingSubgroup = subgroup
            formVC.trip = trip
            formVC.tripId = trip?.id
            formVC.delegate = self
        } else if segue.identifier == "showInviteMembers",
                  let navController = segue.destination as? UINavigationController,
                  let inviteVC = navController.topViewController as? CS05_InviteSubgroupMembersVC,
                  let subgroup = sender as? Subgroup {
            inviteVC.trip = trip
            inviteVC.subgroup = subgroup
            inviteVC.delegate = self
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
        guard var subgroup = subgroup else { return }
        
        // Update subgroup with new members
        subgroup.memberIds = memberIds
        subgroup.updatedAt = Date()
        
        // Save to DataModel
        DataModel.shared.saveSubgroup(subgroup)
        
        // Update local reference
        self.subgroup = subgroup
        
        // Reload UI
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
        cell.configure(with: member, role: "Member")
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard var subgroup = subgroup else { return }
            
            let member = members[indexPath.row]
            
            // Remove member from subgroup
            subgroup.memberIds.removeAll { $0 == member.id }
            subgroup.updatedAt = Date()
            
            // Update DataModel
            DataModel.shared.saveSubgroup(subgroup)
            
            // Update local reference
            self.subgroup = subgroup
            
            // Update local members array
            members.remove(at: indexPath.row)
            
            // Delete row from table
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
