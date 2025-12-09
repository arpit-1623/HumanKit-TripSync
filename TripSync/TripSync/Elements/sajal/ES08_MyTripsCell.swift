//
//  ES08_MyTripsCell.swift
//  TripSync
//
//  Created on 07/12/2025.
//

import UIKit

class MyTripsCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var tripsCollectionView: UICollectionView!
    
    // MARK: - Properties
    private var trips: [Trip] = []
    var onTripSelected: ((Trip) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupCollectionView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    private func setupCollectionView() {
        tripsCollectionView.delegate = self
        tripsCollectionView.dataSource = self
        tripsCollectionView.backgroundColor = .clear
        tripsCollectionView.showsHorizontalScrollIndicator = false
    }
    
    // MARK: - Configuration
    func configure(with trips: [Trip]) {
        self.trips = trips
        tripsCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension MyTripsCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Show at least 1 cell for empty state
        return max(trips.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripCardCell", for: indexPath) as? TripCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // Handle empty state
        if trips.isEmpty {
            configureEmptyCell(cell)
        } else {
            let trip = trips[indexPath.item]
            cell.configure(with: trip)
        }
        
        return cell
    }
    
    private func configureEmptyCell(_ cell: TripCardCollectionViewCell) {
        // Configure cell to show "No trips yet" message
        cell.tripNameLabel.text = "No Trips Yet"
        cell.tripInfoLabel.text = "Join or create a trip to get started"
        cell.tripImageView.image = UIImage(named: "createTripBg")
        cell.contentView.alpha = 0.6
    }
}

// MARK: - UICollectionViewDelegate
extension MyTripsCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Don't trigger action for empty state
        guard !trips.isEmpty else { return }
        
        let selectedTrip = trips[indexPath.item]
        onTripSelected?(selectedTrip)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyTripsCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 200)
    }
}
