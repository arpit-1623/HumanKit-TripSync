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
    @IBOutlet weak var currentTripRedirectButton: UIButton!
    @IBOutlet weak var emptyStateView: UIStackView!
    
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
        // UI setup completed in storyboard
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
            currentTripRedirectButton?.isHidden = true
            emptyStateView?.isHidden = false
            return
        }
        
        // Show current trip info
        currentTripImageView?.isHidden = false
        currentTripNameLabel?.isHidden = false
        currentTripLocationLabel?.isHidden = false
        currentTripRedirectButton?.isHidden = false
        emptyStateView?.isHidden = true
        
        // Configure current trip display
        currentTripImageView?.image = UIImage(named: "createTripBg")
        currentTripNameLabel?.text = trip.name
        currentTripLocationLabel?.text = trip.location
    }
    
    // MARK: - Actions
    @IBAction func currentTripCardTapped(_ sender: UIButton) {
        guard let trip = currentTrip else { return }
        performSegue(withIdentifier: "homeToTripDetails", sender: trip)
    }
    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToTripDetails" {
            if let tripDetailsVC = segue.destination as? TripDetailsViewController,
               let trip = sender as? Trip {
                tripDetailsVC.trip = trip
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
