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
    @IBOutlet weak var currentImageView: UIImageView!
    
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
    }
    
    private func setupTableView() {
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
    }
    
    // MARK: - Actions
    @IBAction func addTripButtonTapped(_ sender: UIBarButtonItem) {
        // Handle add trip
    }
    
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        // Handle filter change
    }
}

// MARK: - UISearchBarDelegate
extension TripsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Handle search
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TripsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        return cell
    }
}
