//
//  CA02_TripDetailsVC.swift
//  TripSync
//
//  Created on 19/11/2025.
//

import UIKit

class TripDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var subgroupsTableView: UITableView!
    
    // MARK: - Properties
    var trip: Trip?
    var subgroups: [Subgroup] = []
    // MARK: - Properties
    var trip: Trip?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubgroupsTableView()
        loadDummyData()
    }
    
    // MARK: - Setup
    private func setupSubgroupsTableView() {
        subgroupsTableView.delegate = self
        subgroupsTableView.dataSource = self
        subgroupsTableView.backgroundColor = .clear
        subgroupsTableView.separatorStyle = .none
        subgroupsTableView.isScrollEnabled = false
    }
    
    private func loadDummyData() {
        let tripId = UUID()
        let userId = UUID()
        
        subgroups = [
            Subgroup(
                name: "Food Explorers",
                description: "For those who want to try food...",
                colorHex: "#FF6B9D",
                tripId: tripId,
                memberIds: [userId]
            ),
            Subgroup(
                name: "Adventure Squad",
                description: "For thrill seekers and explorers",
                colorHex: "#4ECDC4",
                tripId: tripId,
                memberIds: [userId]
            ),
            Subgroup(
                name: "Culture Vultures",
                description: "History and art enthusiasts",
                colorHex: "#FFB84D",
                tripId: tripId,
                memberIds: [userId]
            )
        ]
        
        subgroupsTableView.reloadData()
        updateTableViewHeight()
    }
    
    private func updateTableViewHeight() {
        subgroupsTableView.layoutIfNeeded()
        let height = CGFloat(subgroups.count * 80)
        if let heightConstraint = subgroupsTableView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = height
        }
    }
    
    // MARK: - Menu Actions
    
    @IBAction func shareInviteTapped(_ sender: Any) {
        // TODO: Implement share invite functionality
        // This should present UIActivityViewController with trip invite
        let alert = UIAlertController(title: "Share Invite", message: "Share trip invite functionality will be implemented here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func showQRTapped(_ sender: Any) {
        // TODO: Implement QR code display
        // This should present a modal with generated QR code for the trip
        // let alert = UIAlertController(title: "Show QR", message: "QR code display functionality will be implemented here", preferredStyle: .alert)
        // alert.addAction(UIAlertAction(title: "OK", style: .default))
        // present(alert, animated: true)
        
        performSegue(withIdentifier: "tripDetailsToInviteQR", sender: nil)
    }
    
    @IBAction func editTripTapped(_ sender: Any) {
        // TODO: Implement edit trip functionality
        // This should navigate to edit trip screen
        // let alert = UIAlertController(title: "Edit Trip", message: "Edit trip functionality will be implemented here", preferredStyle: .alert)
        // alert.addAction(UIAlertAction(title: "OK", style: .default))
        // present(alert, animated: true)
        
        performSegue(withIdentifier: "tripDetailsToEditTrip", sender: nil)
    }
    
    // MARK: - Button Actions
    
    @IBAction func mapButtonTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "tripDetailsToMap", sender: self)
    }
    
    @IBAction func chatButtonTapped(_ sender: UITapGestureRecognizer) {
//        let alert = UIAlertController(
//            title: "Chat",
//            message: "Group chat will open here",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
        
        performSegue(withIdentifier: "tripDetailsToChat", sender: nil)
    }
    
    @IBAction func itineraryButtonTapped(_ sender: UITapGestureRecognizer) {
//        let alert = UIAlertController(
//            title: "Itinerary",
//            
//            message: "Trip itinerary will be shown here",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
        
        performSegue(withIdentifier: "tripDetailsToItinerary", sender: nil)
    }
    
    @IBAction func membersButtonTapped(_ sender: UITapGestureRecognizer) {
        // Navigate to members screen
        performSegue(withIdentifier: "tripDetailsToMembers", sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tripDetailsToMap" {
            if let mapVC = segue.destination as? TripMapViewController {
                mapVC.trip = self.trip
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TripDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subgroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubgroupCell", for: indexPath)
        let subgroup = subgroups[indexPath.row]
        
        // Configure cell views using tags
        if let avatarView = cell.contentView.viewWithTag(100) {
            avatarView.backgroundColor = UIColor(hex: subgroup.colorHex) ?? .systemPink
        }
        
        if let nameLabel = cell.contentView.viewWithTag(101) as? UILabel {
            nameLabel.text = subgroup.name
        }
        
        if let descLabel = cell.contentView.viewWithTag(102) as? UILabel {
            descLabel.text = subgroup.description
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Navigate to subgroup details
        let subgroup = subgroups[indexPath.row]
        performSegue(withIdentifier: "tripDetailsToSubgroupDetails", sender: subgroup)
    }
}

// MARK: - Navigation
extension TripDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tripDetailsToSubgroupDetails",
           let destinationVC = segue.destination as? SubgroupDetailsViewController,
           let subgroup = sender as? Subgroup {
            destinationVC.subgroup = subgroup
            destinationVC.trip = self.trip
        }
    }
}
