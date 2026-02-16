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
    @IBOutlet weak var subgroupsEmptyStateView: UIView?
    @IBOutlet weak var subgroupsTableView: UITableView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripDateRangeLabel: UILabel!
    @IBOutlet weak var tripMembersLabel: UILabel!
    @IBOutlet weak var imageAttributionLabel: UILabel?
    @IBOutlet weak var upcomingStopContainerView: UIView?
    @IBOutlet weak var upcomingStopTitleLabel: UILabel?
    @IBOutlet weak var upcomingStopTimeLabel: UILabel?
    @IBOutlet weak var upcomingStopLocationLabel: UILabel?
    @IBOutlet weak var upcomingStopIconImageView: UIImageView?
    @IBOutlet weak var upcomingStopEmptyStateView: UIView?
    
    // MARK: - Properties
    var trip: Trip?
    var subgroups: [Subgroup] = []
    var upcomingStop: ItineraryStop?

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
        setupMenuForRole()
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
        
        // Show/hide empty state
        let isEmpty = subgroups.isEmpty
        subgroupsEmptyStateView?.isHidden = !isEmpty
        subgroupsTableView.isHidden = isEmpty
        
        subgroupsTableView.reloadData()
        
        // Load upcoming stop
        loadUpcomingStop()
    }
    
    private func loadUpcomingStop() {
        guard let trip = trip else { return }
        let allStops = DataModel.shared.getItineraryStops(forTripId: trip.id)
        let now = Date()
        upcomingStop = allStops.filter { $0.time > now }.first
        
        setupUpcomingStopUI()
    }
    
    private func setupUpcomingStopUI() {
        if let stop = upcomingStop {
            // Show upcoming stop, hide empty state
            upcomingStopContainerView?.isHidden = false
            upcomingStopEmptyStateView?.isHidden = true
            
            // Configure title (truncate if needed)
            if stop.title.count > 25 {
                upcomingStopTitleLabel?.text = String(stop.title.prefix(25)) + "..."
            } else {
                upcomingStopTitleLabel?.text = stop.title
            }
            
            // Configure time
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            upcomingStopTimeLabel?.text = timeFormatter.string(from: stop.time)
            
            // Configure location
            upcomingStopLocationLabel?.text = stop.location
            
            // Configure icon
            if let category = stop.category {
                upcomingStopIconImageView?.image = UIImage(systemName: category)
            } else {
                upcomingStopIconImageView?.image = UIImage(systemName: "mappin.and.ellipse")
            }
            upcomingStopIconImageView?.tintColor = .systemOrange
        } else {
            // Hide upcoming stop, show empty state
            upcomingStopContainerView?.isHidden = true
            upcomingStopEmptyStateView?.isHidden = false
        }
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
        guard let currentUser = DataModel.shared.getCurrentUser(),
              let trip = trip,
              trip.isUserAdmin(currentUser.id) else {
            return
        }
        performSegue(withIdentifier: "tripDetailsToEditTrip", sender: nil)
    }
    
    @IBAction func membersMenuTapped(_ sender: Any) {
        performSegue(withIdentifier: "tripDetailsToMembers", sender: nil)
    }
    
    @IBAction func leaveTripTapped(_ sender: Any) {
        guard let trip = trip else { return }
        
        let alert = UIAlertController(
            title: "Leave Trip",
            message: "Are you sure you want to leave \(trip.name)? You will need a new invite code to rejoin.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
            guard let self = self,
                  let tripId = self.trip?.id else { return }
            
            if DataModel.shared.leaveTrip(tripId: tripId) {
                self.navigationController?.popViewController(animated: true)
            } else {
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "Unable to leave the trip. Please try again.",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Button Actions
    @IBAction func mapButtonTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "tripDetailsToMap", sender: self)
    }
    
    @IBAction func itineraryButtonTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "tripDetailsToItinerary", sender: nil)
    }
    
    @IBAction func chatButtonTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "tripDetailsToChat", sender: nil)
    }
    
    @IBAction func alertsButtonTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "tripDetailsToAlerts", sender: nil)
    }
    
    // MARK: - Role-based Menu Setup
    private func setupMenuForRole() {
        guard let currentUser = DataModel.shared.getCurrentUser(),
              let trip = trip else { return }
        
        let isAdmin = trip.isUserAdmin(currentUser.id)
        
        // Create menu actions based on role
        let shareInviteAction = UIAction(title: "Share Invite", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
            self?.shareInviteTapped(self as Any)
        }
        
        let showQRAction = UIAction(title: "Show QR", image: UIImage(systemName: "qrcode")) { [weak self] _ in
            self?.showQRTapped(self as Any)
        }
        
        let membersAction = UIAction(title: "Members", image: UIImage(systemName: "person.2.fill")) { [weak self] _ in
            self?.membersMenuTapped(self as Any)
        }
        
        var menuActions: [UIMenuElement] = [shareInviteAction, showQRAction]
        
        if isAdmin {
            let editTripAction = UIAction(title: "Edit Trip", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.editTripTapped(self as Any)
            }
            menuActions.append(editTripAction)
        } else {
            let leaveTripAction = UIAction(title: "Leave Trip", image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), attributes: .destructive) { [weak self] _ in
                self?.leaveTripTapped(self as Any)
            }
            menuActions.append(leaveTripAction)
        }
        
        menuActions.append(membersAction)
        
        let menu = UIMenu(children: menuActions)
        
        if let rightBarButton = navigationItem.rightBarButtonItem {
            rightBarButton.menu = menu
        }
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
        } else if segue.identifier == "tripDetailsToAlerts",
                  let alertsVC = segue.destination as? AlertsViewController {
            alertsVC.trip = self.trip
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
