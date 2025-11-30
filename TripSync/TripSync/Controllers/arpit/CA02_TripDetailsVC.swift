//
//  CA02_TripDetailsVC.swift
//  TripSync
//
//  Created on 19/11/2025.
//

import UIKit

class TripDetailsViewController: UIViewController, SubgroupFormDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var subgroupsTableView: UITableView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripDateRangeLabel: UILabel!
    
    // MARK: - Properties
    var trip: Trip?
    var subgroups: [Subgroup] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh trip data in case it was edited
        if let tripId = trip?.id {
            if let updatedTrip = DataModel.shared.getTrip(byId: tripId) {
                trip = updatedTrip
                setupUI()
            }
        }
        
        loadData()
    }
    
    // MARK: - Data Loading
    func loadData() {
        guard let trip = trip else { return }
        subgroups = DataModel.shared.getSubgroups(forTripId: trip.id)
        subgroupsTableView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        guard let trip = trip else { 
            return
        }
        
        navigationItem.title = trip.name
        
        tripNameLabel?.text = trip.name
        tripLocationLabel?.text = trip.location
        tripDateRangeLabel?.text = trip.dateRangeString
        
        setupSubgroupsTableView()
    }
    
    private func setupSubgroupsTableView() {
        subgroupsTableView.delegate = self
        subgroupsTableView.dataSource = self
        subgroupsTableView.isScrollEnabled = true
    }
    
    // MARK: - Menu Actions
    @IBAction func shareInviteTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Share Invite", message: "Share trip invite functionality will be implemented here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func showQRTapped(_ sender: Any) {
        performSegue(withIdentifier: "tripDetailsToInviteQR", sender: nil)
    }
    
    @IBAction func editTripTapped(_ sender: Any) {
        performSegue(withIdentifier: "tripDetailsToEditTrip", sender: nil)
    }
    
    // MARK: - Button Actions
    @IBAction func mapButtonTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "tripDetailsToMap", sender: self)
    }
    
    @IBAction func chatButtonTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "tripDetailsToChat", sender: nil)
    }
    
    @IBAction func itineraryButtonTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "tripDetailsToItinerary", sender: nil)
    }
    
    @IBAction func membersButtonTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "tripDetailsToMembers", sender: nil)
    }
    
    // MARK: - Helper Methods
    private func showErrorAndDismiss() {
        let alert = UIAlertController(
            title: "Error",
            message: "Unable to load trip details. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
}

// MARK: - UITableViewDelegate & DataSource
extension TripDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subgroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubgroupCell", for: indexPath) as! TripSubgroupCell
        
        let subgroup = subgroups[indexPath.row]
        cell.update(with: subgroup)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

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
        } else if segue.identifier == "tripDetailsToEditTrip",
                  let navController = segue.destination as? UINavigationController,
                  let editVC = navController.topViewController as? EditTripTableViewController {
            editVC.trip = self.trip
        } else if segue.identifier == "tripDetailsToInviteQR",
                  let navController = segue.destination as? UINavigationController,
                  let inviteVC = navController.topViewController as? InviteQRViewController {
            inviteVC.trip = self.trip
        } else if segue.identifier == "tripDetailsToMap",
                  let mapVC = segue.destination as? TripMapViewController {
            mapVC.trip = self.trip
        } else if segue.identifier == "tripDetailsToChat",
                  let chatVC = segue.destination as? ChatContainerViewController {
            chatVC.trip = self.trip
        } else if segue.identifier == "tripDetailsToItinerary",
                  let itineraryVC = segue.destination as? CS02_ItineraryVC {
            itineraryVC.trip = self.trip
        } else if segue.identifier == "tripDetailsToMembers",
                  let membersVC = segue.destination as? TripMembersViewController {
            membersVC.trip = self.trip
        } else if segue.identifier == "tripDetailsToCreateSubgroup",
                  let navController = segue.destination as? UINavigationController,
                  let formVC = navController.topViewController as? CS04_SubgroupFormVC {
            // Pass trip data
            formVC.trip = self.trip
            formVC.tripId = self.trip?.id
            
            // Set delegate for callback
            formVC.delegate = self
        }
    }
}

// MARK: - SubgroupFormDelegate
extension TripDetailsViewController {
    func didCreateSubgroup(_ subgroup: Subgroup) {
        // Add subgroup to DataModel
        DataModel.shared.saveSubgroup(subgroup)
        
        // Add subgroup ID to trip
        if var trip = self.trip {
            trip.subgroupIds.append(subgroup.id)
            DataModel.shared.saveTrip(trip)
            self.trip = trip
        }
        
        // Reload subgroups
        loadData()
    }
    
    func didUpdateSubgroup(_ subgroup: Subgroup) {
        // Update subgroup in DataModel
        DataModel.shared.saveSubgroup(subgroup)
        
        // Reload subgroups
        loadData()
    }
}
