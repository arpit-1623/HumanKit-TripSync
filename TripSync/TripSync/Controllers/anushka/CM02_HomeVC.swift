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
    @IBOutlet weak var currentTripRedirectButton: UIButton!
    @IBOutlet weak var emptyStateView: UIStackView!
    
    // MARK: - Outlets - Upcoming Trips
    @IBOutlet weak var upcomingTripsTableView: UITableView!
    
    // MARK: - Properties
    private var currentTrip: Trip?
    private var upcomingTrips: [Trip] = []
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
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
    
    deinit {
        upcomingTripsTableView?.removeObserver(self, forKeyPath: "contentSize")
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let tableView = object as? UITableView {
                updateTableViewHeight(tableView)
            }
        }
    }
    
    private func updateTableViewHeight(_ tableView: UITableView) {
        // Remove existing height constraint if it exists
        if let heightConstraint = tableViewHeightConstraint {
            heightConstraint.isActive = false
        }
        
        // Create new height constraint based on content size
        let height = tableView.contentSize.height
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: height)
        tableViewHeightConstraint?.isActive = true
        
        // Trigger layout update
        view.layoutIfNeeded()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // UI setup completed in storyboard
    }
    
    private func setupTableView() {
        upcomingTripsTableView.delegate = self
        upcomingTripsTableView.dataSource = self
        
        // Disable table view scrolling since we want the outer scroll view to handle scrolling
        upcomingTripsTableView.isScrollEnabled = false
        
        // Add observer for content size changes
        upcomingTripsTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        currentTrip = DataModel.shared.getCurrentTrip()
        upcomingTrips = DataModel.shared.getNonCurrentTrips()
        
        updateCurrentTripUI()
        upcomingTripsTableView.reloadData()
        
        // Ensure table view height is updated after data reload
        DispatchQueue.main.async {
            self.updateTableViewHeight(self.upcomingTripsTableView)
        }
    }
    
    // MARK: - UI Update
    private func updateCurrentTripUI() {
        guard let trip = currentTrip else {
            // Show empty state
            currentTripImageView?.isHidden = true
            currentTripNameLabel?.isHidden = true
            currentTripLocationLabel?.isHidden = true
            currentTripDateLabel?.isHidden = true
            currentTripRedirectButton?.isHidden = true
            emptyStateView?.isHidden = false
            return
        }
        
        // Show current trip info
        currentTripImageView?.isHidden = false
        currentTripNameLabel?.isHidden = false
        currentTripLocationLabel?.isHidden = false
        currentTripDateLabel?.isHidden = false
        currentTripRedirectButton?.isHidden = false
        emptyStateView?.isHidden = true
        
        // Configure current trip display
        if let imageURL = trip.coverImageURL {
            UnsplashService.shared.loadImage(from: imageURL, placeholder: UIImage(named: "createTripBg"), into: currentTripImageView!)
        } else if let imageData = trip.coverImageData, let image = UIImage(data: imageData) {
            currentTripImageView?.image = image
        } else {
            currentTripImageView?.image = UIImage(named: "createTripBg")
        }
        currentTripNameLabel?.text = trip.name
        currentTripLocationLabel?.text = trip.location
        currentTripDateLabel?.text = trip.dateRangeString
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
