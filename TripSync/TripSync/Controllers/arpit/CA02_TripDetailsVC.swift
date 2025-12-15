//
//  CA02_TripDetailsVC.swift
//  TripSync
//
//  Created on 19/11/2025.
//

import UIKit

class TripDetailsViewController: UIViewController, SubgroupFormDelegate, EditTripDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet weak var subgroupsTableView: UITableView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripDateRangeLabel: UILabel!
    @IBOutlet weak var tripMembersLabel: UILabel!
    @IBOutlet weak var imageAttributionLabel: UILabel?
    
    // MARK: - Properties
    var trip: Trip?
    var subgroups: [Subgroup] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Verify user has access to this trip
        guard let currentUser = DataModel.shared.getCurrentUser(),
              let trip = trip,
              trip.canUserAccess(currentUser.id) else {
            navigationController?.popViewController(animated: true)
            return
        }

        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUser = DataModel.shared.getCurrentUser() else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        if let tripId = trip?.id {
            if let updatedTrip = DataModel.shared.getTrip(byId: tripId) {
                guard updatedTrip.canUserAccess(currentUser.id) else {
                    navigationController?.popViewController(animated: true)
                    return
                }
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
        
        // Update member count
        let memberCount = trip.memberIds.count
        let memberText = memberCount == 1 ? "1 Member" : "\(memberCount) Members"
        tripMembersLabel?.text = memberText
        
        // Load trip cover image
        if let imageURL = trip.coverImageURL {
            UnsplashService.shared.loadImage(from: imageURL, placeholder: UIImage(named: "createTripBg"), into: backgroundImageView!)
        } else if let imageData = trip.coverImageData, let image = UIImage(data: imageData) {
            backgroundImageView?.image = image
        } else {
            backgroundImageView?.image = UIImage(named: "createTripBg")
        }
        
        if let photographerName = trip.coverImagePhotographerName {
            imageAttributionLabel?.text = "Photo by \(photographerName) on Unsplash"
            imageAttributionLabel?.isHidden = false
        } else {
            imageAttributionLabel?.isHidden = true
        }
        
        setupSubgroupsTableView()
    }
    
    private func setupSubgroupsTableView() {
        subgroupsTableView.delegate = self
        subgroupsTableView.dataSource = self
        subgroupsTableView.isScrollEnabled = false
    }
    
    // MARK: - Menu Actions
    @IBAction func shareInviteTapped(_ sender: Any) {
        guard let trip = trip else { return }
        
        let activityVC = ShareInviteViewController.configureActivityVC(trip: trip)
        present(activityVC, animated: true)
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
    
    // MARK: - Navigation
    @IBAction func unwindToTripDetails(segue: UIStoryboardSegue) {
        
    }
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
            editVC.delegate = self
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

            formVC.trip = self.trip
            formVC.tripId = self.trip?.id
            
            formVC.delegate = self
        }
    }
}

// MARK: - SubgroupFormDelegate
extension TripDetailsViewController {
    func didCreateSubgroup(_ subgroup: Subgroup) {
        DataModel.shared.saveSubgroup(subgroup)
        
        if var trip = self.trip {
            trip.subgroupIds.append(subgroup.id)
            DataModel.shared.saveTrip(trip)
            self.trip = trip
        }
        
        loadData()
    }
    
    func didUpdateSubgroup(_ subgroup: Subgroup) {
        DataModel.shared.saveSubgroup(subgroup)
        
        loadData()
    }
}

// MARK: - EditTripDelegate
extension TripDetailsViewController {
    func didUpdateTrip() {
        if let tripId = trip?.id,
           let updatedTrip = DataModel.shared.getTrip(byId: tripId) {
            trip = updatedTrip
            setupUI()
        }
    }
}
