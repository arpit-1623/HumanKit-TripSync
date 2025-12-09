//
//  EM02_UpcomingTripCell.swift
//  TripSync
//
//  Created by Arpit Garg on 24/11/25.
//

import UIKit

class UpcomingTripCell: UITableViewCell {
    
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripDateLabel: UILabel!
    @IBOutlet weak var tripMembersLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with trip: Trip) {
        tripNameLabel.text = trip.name
        tripDateLabel.text = trip.dateRangeString
        tripMembersLabel.text = "\(trip.memberCount) members"
        
        // Load image from URL or show placeholder
        if let imageURL = trip.coverImageURL {
            UnsplashService.shared.loadImage(from: imageURL, placeholder: UIImage(named: "createTripBg"), into: tripImageView)
        } else if let imageData = trip.coverImageData, let image = UIImage(data: imageData) {
            tripImageView.image = image
        } else {
            tripImageView.image = UIImage(named: "createTripBg")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
