//
//  CA01_TripsVC.swift
//  TripSync
//
//  Created by Arpit Garg on 18/11/25.
//

import UIKit

class TripsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var currentTripLabel: UILabel!
    @IBOutlet weak var currentTripCard: UIView!
    @IBOutlet weak var currentTripImageView: UIImageView!
    @IBOutlet weak var currentTripNameLabel: UILabel!
    @IBOutlet weak var currentTripLocationLabel: UILabel!
    @IBOutlet weak var currentTripDateRangeLabel: UILabel!
    @IBOutlet weak var currentTripMembersLabel: UILabel!
    
    @IBOutlet weak var otherTripsLabel: UILabel!
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tripsTableView: UITableView!
    
    // MARK: - Properties
    private var currentTrip: Trip?
    private var otherTrips: [Trip] = []
    private var filteredTrips: [Trip] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
        
        loadData()
    }

    // MARK: - Data Loading
    private func loadData() {
        guard let currentUser = DataModel.shared.getCurrentUser() else { return }
        
        currentTrip = DataModel.shared.getCurrentTrip()
        otherTrips = DataModel.shared.getNonCurrentTrips()
        filteredTrips = otherTrips
        
        configureCurrentTripUI()
        tripsTableView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        searchBar.delegate = self
        
        // Add tap gesture to current trip card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(currentTripCardTapped))
        currentTripCard.addGestureRecognizer(tapGesture)
        currentTripCard.isUserInteractionEnabled = true
    }
    
    private func setupTableView() {
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
    }
    
    func configureCurrentTripUI() {
        guard let trip = currentTrip else {
            currentTripCard.isHidden = true
            currentTripLabel.text = "No current trip"
            return
        }
        
        currentTripCard.isHidden = false
        currentTripImageView.image = UIImage(systemName: "photo")
        currentTripNameLabel.text = trip.name
        currentTripLocationLabel.text = trip.location
        currentTripDateRangeLabel.text = trip.dateRangeString
        currentTripMembersLabel.text = String(trip.memberCount)
    }
    
    // MARK: - Actions
    @IBAction func addTripButtonTapped(_ sender: UIBarButtonItem) {
        // Handle add trip
        print("Add trip tapped")
    }
    
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        // Handle filter change
        print("Filter changed to index: \(sender.selectedSegmentIndex)")
    }
    
    @objc private func currentTripCardTapped() {
        guard let trip = currentTrip else { return }
        performSegue(withIdentifier: "tripsToTripDetails", sender: trip)
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        switch filterSegmentedControl.selectedSegmentIndex {
        case 0:
            // All Trips
            filteredTrips = otherTrips
        case 1:
            // Upcoming Trips
            filteredTrips = otherTrips.filter { $0.status == .upcoming }
        case 2:
            // Past Trips
            filteredTrips = otherTrips.filter { $0.status == .past }
        default:
            break
        }
        tripsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tripsToTripDetails",
           let tripDetailsVC = segue.destination as? TripDetailsViewController {
            // Handle trip from both table view selection and current trip card tap
            if let trip = sender as? Trip {
                tripDetailsVC.trip = trip
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension TripsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredTrips = otherTrips
        } else {
            filteredTrips = otherTrips.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        tripsTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TripsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as? TripTableViewCell else {
            return UITableViewCell()
        }
        
        let trip = filteredTrips[indexPath.row]
        cell.update(with: trip)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrip = filteredTrips[indexPath.row]
        performSegue(withIdentifier: "tripsToTripDetails", sender: selectedTrip)
    }
}
