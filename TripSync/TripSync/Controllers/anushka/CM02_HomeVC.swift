//
//  CM02_HomeVC.swift
//  TripSync
//
//  Created by Arpit Garg on 24/11/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Outlets - Greeting Section
    @IBOutlet weak var greetingStack: UIStackView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var subGreetingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    // MARK: - Outlets - Current Trip Section
    @IBOutlet weak var currentTripCard: UIView!
    @IBOutlet weak var currentTripImageView: UIImageView!
    @IBOutlet weak var currentTripNameLabel: UILabel!
    @IBOutlet weak var currentTripLocationLabel: UILabel!
    @IBOutlet weak var currentTripDateLabel: UILabel!
    @IBOutlet weak var currentTripRedirectButton: UIButton!
    @IBOutlet weak var currentTripBlurView: UIVisualEffectView!
    @IBOutlet weak var emptyStateView: UIStackView!
    
    // MARK: - Outlets - Empty State
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var emptyStateContainer: UIView!
    @IBOutlet weak var emptyGreetingLabel: UILabel!
    @IBOutlet weak var emptySubGreetingLabel: UILabel!
    @IBOutlet weak var emptyLocationLabel: UILabel!
    
    // MARK: - Outlets - Upcoming Trips
    @IBOutlet weak var upcomingCollectionView: UICollectionView!
    @IBOutlet weak var upcomingTripsHeaderLabel: UILabel!
    @IBOutlet weak var upcomingEmptyStateView: UIStackView!
    
    // MARK: - Properties
    private var currentTrip: Trip?
    private var upcomingTrips: [Trip] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    
    // MARK: - Setup
    private func setupUI() {
        // UI is configured in storyboard
    }
    
    private func setupCollectionView() {
        upcomingCollectionView.delegate = self
        upcomingCollectionView.dataSource = self
    }
    
    // MARK: - Data Loading
    private func loadData() {
        guard let currentUser = DataModel.shared.getCurrentUser() else { return }
        
        let userTrips = DataModel.shared.getUserAccessibleTrips(currentUser.id)
        
        // Check if user has any trips and toggle empty state
        if userTrips.isEmpty {
            mainScrollView?.isHidden = true
            greetingStack?.isHidden = true
            emptyStateContainer?.isHidden = false
            view.bringSubviewToFront(emptyStateContainer)
        } else {
            mainScrollView?.isHidden = false
            greetingStack?.isHidden = false
            emptyStateContainer?.isHidden = true
        }
        
        currentTrip = userTrips.first { $0.status == .current }
        upcomingTrips = userTrips.filter { $0.status == .upcoming }
        
        updateGreeting()
        updateCurrentTripUI()
        updateUpcomingTripsUI()
        upcomingCollectionView.reloadData()
    }
    
    // MARK: - UI Update
    private func updateGreeting() {
        guard let currentUser = DataModel.shared.getCurrentUser() else { return }
        
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 0..<12:
            timeGreeting = "Good Morning"
        case 12..<17:
            timeGreeting = "Good Afternoon"
        case 17..<21:
            timeGreeting = "Good Evening"
        default:
            timeGreeting = "Good Night"
        }
        
        let firstName = currentUser.fullName.components(separatedBy: " ").first ?? currentUser.fullName
        
        // Update regular greeting
        greetingLabel?.text = "\(timeGreeting), \(firstName)"
        
        // Update empty state greeting
        emptyGreetingLabel?.text = "\(timeGreeting), \(firstName)"
        
        if let trip = currentTrip {
            subGreetingLabel?.text = "Have fun on your trip to"
            locationLabel?.text = trip.location
        } else {
            subGreetingLabel?.text = "Ready to plan your"
            locationLabel?.text = "next adventure?"
            
            // Update empty state greeting text
            emptySubGreetingLabel?.text = "Ready to plan your"
            emptyLocationLabel?.text = "next adventure?"
        }
    }
    
    private func updateCurrentTripUI() {
        guard let trip = currentTrip else {
            // Show empty state
            currentTripImageView?.isHidden = true
            currentTripNameLabel?.isHidden = true
            currentTripLocationLabel?.isHidden = true
            currentTripDateLabel?.isHidden = true
            currentTripRedirectButton?.isHidden = true
            currentTripBlurView?.isHidden = true
            emptyStateView?.isHidden = false
            return
        }
        
        // Show current trip info
        currentTripImageView?.isHidden = false
        currentTripNameLabel?.isHidden = false
        currentTripLocationLabel?.isHidden = false
        currentTripDateLabel?.isHidden = false
        currentTripRedirectButton?.isHidden = false
        currentTripBlurView?.isHidden = false
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
    
    private func updateUpcomingTripsUI() {
        let hasUpcomingTrips = !upcomingTrips.isEmpty
        
        // Hide entire section (header + collection view) when no upcoming trips
        upcomingTripsHeaderLabel?.isHidden = !hasUpcomingTrips
        upcomingCollectionView?.isHidden = !hasUpcomingTrips
        upcomingEmptyStateView?.isHidden = hasUpcomingTrips
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
        } else if segue.identifier == "homeToNotifications" {
            // Notifications modal is presented
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingTrips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripCardCell", for: indexPath) as? TripCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let trip = upcomingTrips[indexPath.item]
        cell.configure(with: trip)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let trip = upcomingTrips[indexPath.item]
        performSegue(withIdentifier: "homeToTripDetails", sender: trip)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 200)
    }
}
