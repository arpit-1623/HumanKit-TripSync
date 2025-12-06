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
    
    @IBOutlet weak var currentTripCard: UIView!
    @IBOutlet weak var currentTripImageView: UIImageView!
    @IBOutlet weak var currentTripNameLabel: UILabel!
    @IBOutlet weak var currentTripDetailsLabel: UILabel!
    
    @IBOutlet weak var upcomingCollectionView: UICollectionView!
    @IBOutlet weak var pastCollectionView: UICollectionView!
    
    // MARK: - Properties
    private var currentTrip: Trip?
    private var upcomingTrips: [Trip] = []
    private var pastTrips: [Trip] = []
    private var allTrips: [Trip] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViews()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    // MARK: - Data Loading
    private func loadData() {
        guard let currentUser = DataModel.shared.getCurrentUser() else { return }
        
        currentTrip = DataModel.shared.getCurrentTrip()
        
        // Get all non-current trips
        let nonCurrentTrips = DataModel.shared.getNonCurrentTrips()
        
        // Filter by status
        upcomingTrips = nonCurrentTrips.filter { $0.status == .upcoming }
        pastTrips = nonCurrentTrips.filter { $0.status == .past }
        allTrips = nonCurrentTrips
        
        configureCurrentTripUI()
        upcomingCollectionView.reloadData()
        pastCollectionView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        searchBar.delegate = self
        searchBar.placeholder = "Search Trips..."
        searchBar.showsCancelButton = false
    }
    
    private func setupCollectionViews() {
        upcomingCollectionView.delegate = self
        upcomingCollectionView.dataSource = self
        
        pastCollectionView.delegate = self
        pastCollectionView.dataSource = self
    }
    
    func configureCurrentTripUI() {
        guard let trip = currentTrip else {
            currentTripCard.isHidden = true
            return
        }
        
        currentTripCard.isHidden = false
        
        // Load image from URL or show placeholder
        if let imageURL = trip.coverImageURL {
            UnsplashService.shared.loadImage(from: imageURL, placeholder: UIImage(named: "createTripBg"), into: currentTripImageView)
        } else if let imageData = trip.coverImageData, let image = UIImage(data: imageData) {
            currentTripImageView.image = image
        } else {
            currentTripImageView.image = UIImage(named: "createTripBg")
        }
        
        currentTripNameLabel.text = trip.name
        currentTripDetailsLabel.text = "\(trip.location) • \(trip.memberCount) members"
    }
    
    private func performSearch(searchText: String) {
        guard !searchText.isEmpty else {
            // Reset to original data
            upcomingTrips = allTrips.filter { $0.status == .upcoming }
            pastTrips = allTrips.filter { $0.status == .past }
            upcomingCollectionView.reloadData()
            pastCollectionView.reloadData()
            return
        }
        
        // Filter trips
        let filtered = allTrips.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
        
        upcomingTrips = filtered.filter { $0.status == .upcoming }
        pastTrips = filtered.filter { $0.status == .past }
        
        upcomingCollectionView.reloadData()
        pastCollectionView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func currentTripCardTapped(_ sender: UITapGestureRecognizer) {
        guard let trip = currentTrip else { return }
        performSegue(withIdentifier: "tripsToTripDetails", sender: trip)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tripsToTripDetails",
           let tripDetailsVC = segue.destination as? TripDetailsViewController {
            if let trip = sender as? Trip {
                tripDetailsVC.trip = trip
            }
        }
    }
    
    @IBAction func unwindToTrips(segue: UIStoryboardSegue) {
        
    }
}

// MARK: - UISearchBarDelegate
extension TripsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        performSearch(searchText: "")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension TripsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == upcomingCollectionView {
            return upcomingTrips.count
        } else {
            return pastTrips.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripCardCell", for: indexPath) as? TripCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let trip = collectionView == upcomingCollectionView ? upcomingTrips[indexPath.item] : pastTrips[indexPath.item]
        cell.configure(with: trip)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTrip = collectionView == upcomingCollectionView ? upcomingTrips[indexPath.item] : pastTrips[indexPath.item]
        performSegue(withIdentifier: "tripsToTripDetails", sender: selectedTrip)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 200)
    }
}
