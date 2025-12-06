//
//  EA03_TripCardCell.swift
//  TripSync
//
//  Created by GitHub Copilot on 06/12/25.
//

import UIKit

class TripCardCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        tripImageView.contentMode = .scaleAspectFill
        tripImageView.layer.cornerRadius = 20
        tripImageView.layer.masksToBounds = true
    }
    
    func configure(with trip: Trip) {
        tripNameLabel.text = trip.name
        tripInfoLabel.text = "\(trip.location) • \(trip.startDate.formatted(date: .abbreviated, time: .omitted))"
        
        // Load image from URL or show placeholder
        if let imageURL = trip.coverImageURL {
            UnsplashService.shared.loadImage(from: imageURL, placeholder: UIImage(named: "createTripBg"), into: tripImageView)
        } else if let imageData = trip.coverImageData, let image = UIImage(data: imageData) {
            tripImageView.image = image
        } else {
            tripImageView.image = UIImage(named: "createTripBg")
        }
    }
}
