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
        
        // Check if user has any trips, if not navigate to empty trips screen
        checkForEmptyState()
        
        loadData()
    }
    
    // MARK: - Empty State Check
    private func checkForEmptyState() {
        guard let currentUser = DataModel.shared.getCurrentUser() else { return }
        let userTrips = DataModel.shared.getUserAccessibleTrips(currentUser.id)
        
        // If user has no trips, navigate to empty trips screen in tab bar
        if userTrips.isEmpty {
            navigateToEmptyTripsScreen()
        }
    }
    
    private func navigateToEmptyTripsScreen() {
        // Get the navigation controller and tab bar controller
        guard let navigationController = self.navigationController,
              let tabBarController = navigationController.tabBarController else {
            return
        }
        
        // Load the empty trips screen storyboard
        let emptyTripsStoryboard = UIStoryboard(name: "SD07_EmptyTripsScreen", bundle: nil)
        guard let emptyTripsNav = emptyTripsStoryboard.instantiateInitialViewController() else {
            return
        }
        
        // Find the index of the Trips tab
        if let viewControllers = tabBarController.viewControllers,
           let tripsIndex = viewControllers.firstIndex(where: { ($0 as? UINavigationController)?.topViewController is TripsViewController }) {
            
            // Preserve the tab bar item from the original trips tab
            let originalTabBarItem = viewControllers[tripsIndex].tabBarItem
            emptyTripsNav.tabBarItem = originalTabBarItem
            
            // Replace the trips tab with the empty trips screen
            var updatedViewControllers = viewControllers
            updatedViewControllers[tripsIndex] = emptyTripsNav
            tabBarController.viewControllers = updatedViewControllers
            
            // Set the selected index to the trips tab
            tabBarController.selectedIndex = tripsIndex
        }
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
        upcomingCollectionView.reloadData()
        pastCollectionView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        searchBar.delegate = self
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
