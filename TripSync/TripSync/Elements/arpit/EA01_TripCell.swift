//
//  TripTableViewCell.swift
//  TripSync
//
//  Created by Arpit Garg on 19/11/25.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func dummy(_ name: String, _ location: String, _ date: String) {
        tripNameLabel.text = name
        tripLocationLabel.text = location
        tripDateLabel.text = date
        
        // MARK: - Temporary Image
        tripImageView.image = UIImage(systemName: "photo")
        tripImageView.tintColor = .systemGray3
    }
    
    func update(with trip: Trip) {
        tripNameLabel.text = trip.name
        tripLocationLabel.text = trip.location
        
        let dateString = trip.dateRangeString
        tripDateLabel.text = dateString
        
        // MARK: - Temporary Image
        tripImageView.image = UIImage(systemName: "photo")
        tripImageView.tintColor = .systemGray3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
