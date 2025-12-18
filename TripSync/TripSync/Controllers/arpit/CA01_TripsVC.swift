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
    
    @IBOutlet weak var allEmptyStateView: UIView!
    
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var currentTripCard: UIView!
    @IBOutlet weak var currentTripImageView: UIImageView!
    @IBOutlet weak var currentTripNameLabel: UILabel!
    @IBOutlet weak var currentTripDetailsLabel: UILabel!
    
    @IBOutlet weak var currentTripEmptyStateView: UIView!
    @IBOutlet weak var currentTripEmptyStateImageView: UIImageView!
    @IBOutlet weak var currentTripEmptyStateLabel: UILabel!
    
    @IBOutlet weak var upcomingLabel: UILabel!
    @IBOutlet weak var upcomingCollectionView: UICollectionView!
    @IBOutlet weak var pastCollectionView: UICollectionView!
    
    @IBOutlet weak var upcomingEmptyStateView: UIView!
    @IBOutlet weak var upcomingEmptyStateImageView: UIImageView!
    @IBOutlet weak var upcomingEmptyStateLabel: UILabel!
    
    @IBOutlet weak var pastLabel: UILabel!
    @IBOutlet weak var pastEmptyStateView: UIView!
    @IBOutlet weak var pastEmptyStateImageView: UIImageView!
    @IBOutlet weak var pastEmptyStateLabel: UILabel!
    
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
        
        // Get only trips where current user is a member
        let userTrips = DataModel.shared.getUserAccessibleTrips(currentUser.id)
        
        // Filter by status
        currentTrip = userTrips.first { $0.status == .current }
        upcomingTrips = userTrips.filter { $0.status == .upcoming }
        pastTrips = userTrips.filter { $0.status == .past }
        allTrips = userTrips.filter { $0.status != .current }
        
        configureCurrentTripUI()
        updateAllEmptyState()
        updateEmptyStates()
        upcomingCollectionView.reloadData()
        pastCollectionView.reloadData()
    }
    
    private func updateEmptyStates() {
        // Don't show individual empty states when showing all-empty state
        let isAllEmpty = currentTrip == nil && upcomingTrips.isEmpty && pastTrips.isEmpty
        if isAllEmpty {
            return
        }
        
        // Show/hide upcoming empty state
        let hasUpcomingTrips = !upcomingTrips.isEmpty
        upcomingEmptyStateView.isHidden = hasUpcomingTrips
        upcomingCollectionView.isHidden = !hasUpcomingTrips
        
        // Show/hide past empty state
        let hasPastTrips = !pastTrips.isEmpty
        pastEmptyStateView.isHidden = hasPastTrips
        pastCollectionView.isHidden = !hasPastTrips
    }
    
    private func updateAllEmptyState() {
        let isAllEmpty = currentTrip == nil && upcomingTrips.isEmpty && pastTrips.isEmpty
        
        allEmptyStateView.isHidden = !isAllEmpty
        
        // Update navigation title
        navigationItem.title = isAllEmpty ? "" : "Your Trips"
        
        // Hide all content when showing all-empty state
        searchBar.isHidden = isAllEmpty
        currentLabel.isHidden = isAllEmpty
        upcomingLabel.isHidden = isAllEmpty
        pastLabel.isHidden = isAllEmpty
        
        currentTripCard.isHidden = isAllEmpty || currentTrip == nil
        currentTripEmptyStateView.isHidden = isAllEmpty || currentTrip != nil
        upcomingCollectionView.isHidden = isAllEmpty
        upcomingEmptyStateView.isHidden = isAllEmpty
        pastCollectionView.isHidden = isAllEmpty
        pastEmptyStateView.isHidden = isAllEmpty
    }
    
    // MARK: - Setup
    private func setupUI() {
        searchBar.delegate = self
        setupEmptyStates()
    }
    
    private func setupEmptyStates() {
        // Current trip empty state
        currentTripEmptyStateImageView.image = UIImage(systemName: "airplane.departure")
        currentTripEmptyStateImageView.tintColor = .systemGray
        currentTripEmptyStateImageView.contentMode = .scaleAspectFit
        currentTripEmptyStateLabel.text = "No active trip\nJoin or create a trip to get started"
        currentTripEmptyStateLabel.textAlignment = .center
        currentTripEmptyStateLabel.numberOfLines = 0
        currentTripEmptyStateLabel.textColor = .secondaryLabel
        currentTripEmptyStateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Upcoming empty state
        upcomingEmptyStateImageView.image = UIImage(systemName: "calendar.badge.plus")
        upcomingEmptyStateImageView.tintColor = .systemGray
        upcomingEmptyStateImageView.contentMode = .scaleAspectFit
        upcomingEmptyStateLabel.text = "No upcoming trips yet\nCreate or join a trip to start planning"
        upcomingEmptyStateLabel.textAlignment = .center
        upcomingEmptyStateLabel.numberOfLines = 0
        upcomingEmptyStateLabel.textColor = .secondaryLabel
        upcomingEmptyStateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Past empty state
        pastEmptyStateImageView.image = UIImage(systemName: "clock.arrow.circlepath")
        pastEmptyStateImageView.tintColor = .systemGray
        pastEmptyStateImageView.contentMode = .scaleAspectFit
        pastEmptyStateLabel.text = "No past trips yet\nYour completed trips will appear here"
        pastEmptyStateLabel.textAlignment = .center
        pastEmptyStateLabel.numberOfLines = 0
        pastEmptyStateLabel.textColor = .secondaryLabel
        pastEmptyStateLabel.font = .systemFont(ofSize: 16, weight: .medium)
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
            currentTripEmptyStateView.isHidden = false
            return
        }
        
        currentTripCard.isHidden = false
        currentTripEmptyStateView.isHidden = true
        
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
            upcomingTrips = allTrips.filter { $0.status == .upcoming }
            pastTrips = allTrips.filter { $0.status == .past }
            upcomingCollectionView.reloadData()
            pastCollectionView.reloadData()
            return
        }
        
        let filtered = allTrips.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
        
        upcomingTrips = filtered.filter { $0.status == .upcoming }
        pastTrips = filtered.filter { $0.status == .past }
        
        updateEmptyStates()
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
