//
//  ES03_SubgroupFilterCell.swift
//  TripSync
//
//  Created by Sajal Garg on 20/11/25.
//

import UIKit

class ES03_SubgroupFilterCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        // Container styling
        containerView.layer.cornerRadius = 25
        
        // Icon styling
        iconLabel.font = .systemFont(ofSize: 18)
        
        // Name label styling
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
    }
    
    // MARK: - Configuration
    func configure(name: String, colorHex: String, isSelected: Bool, showStar: Bool) {
        nameLabel.text = name
        iconLabel.text = showStar ? "⭐" : ""
        
        let color = UIColor(hex: colorHex) ?? .systemBlue
        
        if isSelected {
            containerView.backgroundColor = color
            nameLabel.textColor = .white
        } else {
            containerView.backgroundColor = UIColor.systemGray5
            nameLabel.textColor = .secondaryLabel
        }
    }
}
