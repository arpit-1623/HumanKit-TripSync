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
        guard let trip = trip else { return }
        
        // Load all trip members
        allTripMembers = trip.memberIds.compactMap { memberId in
            DataModel.shared.getUser(byId: memberId)
        }
        
        // Pre-select existing subgroup members
        if let subgroup = subgroup {
            selectedMemberIds = Set(subgroup.memberIds)
        }
    }
    
    private func setupNavigationBar() {
        title = "Invite"
        
        // Close button
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .label
        navigationItem.leftBarButtonItem = closeButton
        
        // Add button with count
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
        let title = "Add (\(count))"
        let addButton = UIBarButtonItem(
            title: title,
            style: .done,
            target: self,
            action: #selector(addButtonTapped)
        )
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
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addButtonTapped() {
        delegate?.didUpdateMembers(Array(selectedMemberIds))
        dismiss(animated: true)
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
