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
    @IBOutlet weak var otherTripsLabel: UILabel!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tripsTableView: UITableView!
    @IBOutlet weak var currentTripImageView: UIImageView!
    
    // MARK: - Properties
    // Dummy data for testing
    private let dummyTrips: [(name: String, location: String, date: String)] = [
        ("Paris Adventure", "Paris, France", "Dec 10 - Dec 17"),
        ("Tokyo Explorer", "Tokyo, Japan", "Jan 5 - Jan 12"),
        ("New York City Break", "New York, USA", "Oct 20 - Oct 23"),
        ("Bali Beach Vacation", "Bali, Indonesia", "Feb 15 - Mar 1"),
        ("London History Tour", "London, UK", "Sep 8 - Sep 15")
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure UI elements
        searchBar.delegate = self
        
        // Set placeholder image for current trip
        currentTripImageView.image = UIImage(systemName: "photo")
        currentTripImageView.tintColor = .systemGray3
    }
    
    private func setupTableView() {
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
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
}

// MARK: - UISearchBarDelegate
extension TripsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Handle search
        print("Searching for: \(searchText)")
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TripsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as? TripTableViewCell else {
            return UITableViewCell()
        }
        
        let trip = dummyTrips[indexPath.row]
        
        // Use the dummy function to populate the cell
        cell.dummy(trip.name, trip.location, trip.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTrip = dummyTrips[indexPath.row]
        print("Selected trip: \(selectedTrip.name)")
    }
}
