//
//  CM02_HomeVC.swift
//  TripSync
//
//  Created by Arpit Garg on 24/11/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Outlets - Current Trip Section
    @IBOutlet weak var currentTripCard: UIView!
    @IBOutlet weak var currentTripImageView: UIImageView!
    @IBOutlet weak var currentTripNameLabel: UILabel!
    @IBOutlet weak var currentTripLocationLabel: UILabel!
    @IBOutlet weak var currentTripDateLabel: UILabel!
    @IBOutlet weak var currentTripMembersLabel: UILabel!
    @IBOutlet weak var emptyStateView: UIStackView!
    
    // MARK: - Outlets - Action Buttons
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var itineraryButton: UIButton!
    @IBOutlet weak var membersButton: UIButton!
    
    // MARK: - Outlets - Upcoming Trips
    @IBOutlet weak var upcomingTripsTableView: UITableView!
    
    // MARK: - Properties
    private var currentTrip: Trip?
    private var upcomingTrips: [Trip] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Add tap gesture to current trip card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(currentTripCardTapped))
        currentTripCard.addGestureRecognizer(tapGesture)
        currentTripCard.isUserInteractionEnabled = true
    }
    
    private func setupTableView() {
        upcomingTripsTableView.delegate = self
        upcomingTripsTableView.dataSource = self
    }
    
    // MARK: - Data Loading
    private func loadData() {
        currentTrip = DataModel.shared.getCurrentTrip()
        upcomingTrips = DataModel.shared.getNonCurrentTrips()
        
        updateCurrentTripUI()
        upcomingTripsTableView.reloadData()
    }
    
    // MARK: - UI Update
    private func updateCurrentTripUI() {
        guard let trip = currentTrip else {
            // Show empty state
            currentTripImageView?.isHidden = true
            currentTripNameLabel?.isHidden = true
            currentTripLocationLabel?.isHidden = true
            currentTripDateLabel?.isHidden = true
            currentTripMembersLabel?.isHidden = true
            emptyStateView?.isHidden = false
            
            // Disable action buttons
            mapButton?.isEnabled = false
            mapButton?.alpha = 0.5
            chatButton?.isEnabled = false
            chatButton?.alpha = 0.5
            itineraryButton?.isEnabled = false
            itineraryButton?.alpha = 0.5
            membersButton?.isEnabled = false
            membersButton?.alpha = 0.5
            return
        }
        
        // Show current trip info
        currentTripImageView?.isHidden = false
        currentTripNameLabel?.isHidden = false
        currentTripLocationLabel?.isHidden = false
        currentTripDateLabel?.isHidden = false
        currentTripMembersLabel?.isHidden = false
        emptyStateView?.isHidden = true
        
        // Enable action buttons
        mapButton?.isEnabled = true
        mapButton?.alpha = 1.0
        chatButton?.isEnabled = true
        chatButton?.alpha = 1.0
        itineraryButton?.isEnabled = true
        itineraryButton?.alpha = 1.0
        membersButton?.isEnabled = true
        membersButton?.alpha = 1.0
        
        currentTripImageView?.image = UIImage(named: "createTripBg")
        currentTripNameLabel?.text = trip.name
        currentTripLocationLabel?.text = trip.location
        currentTripDateLabel?.text = trip.dateRangeString
        currentTripMembersLabel?.text = "\(trip.memberCount) Members"
    }
    
    // MARK: - Actions
    @objc private func currentTripCardTapped() {
        guard let trip = currentTrip else { return }
        performSegue(withIdentifier: "homeToTripDetails", sender: trip)
    }
    
    @IBAction func mapButtonTapped(_ sender: UIButton) {
        guard let trip = currentTrip else {
            showNoCurrentTripAlert()
            return
        }
        performSegue(withIdentifier: "homeToMap", sender: trip)
    }
    
    @IBAction func chatButtonTapped(_ sender: UIButton) {
        guard let trip = currentTrip else {
            showNoCurrentTripAlert()
            return
        }
        performSegue(withIdentifier: "homeToChat", sender: trip)
    }
    
    @IBAction func itineraryButtonTapped(_ sender: UIButton) {
        guard let trip = currentTrip else {
            showNoCurrentTripAlert()
            return
        }
        performSegue(withIdentifier: "homeToItinerary", sender: trip)
    }
    
    @IBAction func membersButtonTapped(_ sender: UIButton) {
        guard let trip = currentTrip else {
            showNoCurrentTripAlert()
            return
        }
        performSegue(withIdentifier: "homeToMembers", sender: trip)
    }
    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Helper Methods
    private func showNoCurrentTripAlert() {
        let alert = UIAlertController(title: "No Current Trip", message: "You need to have an active trip to access this feature.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToTripDetails" {
            if let tripDetailsVC = segue.destination as? TripDetailsViewController,
               let trip = sender as? Trip {
                tripDetailsVC.trip = trip
            }
        } else if segue.identifier == "homeToMap" {
            // TODO: Pass trip to map view controller when implemented
            if let trip = sender as? Trip {
                // mapVC.trip = trip
            }
        } else if segue.identifier == "homeToChat" {
            // TODO: Pass trip to chat view controller when implemented
            if let trip = sender as? Trip {
                // chatVC.trip = trip
            }
        } else if segue.identifier == "homeToItinerary" {
            // TODO: Pass trip to itinerary view controller when implemented
            if let trip = sender as? Trip {
                // itineraryVC.trip = trip
            }
        } else if segue.identifier == "homeToMembers" {
            // TODO: Pass trip to members view controller when implemented
            if let trip = sender as? Trip {
                // membersVC.trip = trip
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTripCell", for: indexPath) as? UpcomingTripCell else {
            return UITableViewCell()
        }
        
        let trip = upcomingTrips[indexPath.row]
        cell.configure(with: trip)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let trip = upcomingTrips[indexPath.row]
        performSegue(withIdentifier: "homeToTripDetails", sender: trip)
    }
}
