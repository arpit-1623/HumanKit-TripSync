//
//  ES04_CategoryIconCell.swift
//  TripSync
//
//  Created by Sajal Garg on 01/12/25.
//

import UIKit

class ES04_CategoryIconCell: UICollectionViewCell {
    
    // MARK: - Outlets (connected in SS02_Itinerary.storyboard)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK: - Configuration
    func configure(iconName: String, isSelected: Bool) {
        iconImageView.image = UIImage(systemName: iconName)
        
        if isSelected {
            containerView.backgroundColor = .systemBlue
            iconImageView.tintColor = .white
        } else {
            containerView.backgroundColor = .systemGray4
            iconImageView.tintColor = .white
        }
    }
}
