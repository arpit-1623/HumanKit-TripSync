//
//  EA03_MemberMapCell.swift
//  TripSync
//
//  Created by Arpit Garg on 21/11/25.
//

import UIKit

class MemberMapCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var avatarInitialsLabel: UILabel!
    @IBOutlet weak var statusIndicator: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var navigateIcon: UIImageView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // All static styling is now in storyboard
        // backgroundColor, selectionStyle, corner radius, and clipsToBounds are set in storyboard
    }
    
    // MARK: - Configuration
    func configure(with member: User, location: UserLocation?) {
        // Set name
        nameLabel.text = member.fullName
        
        // Set initials and avatar color
        avatarInitialsLabel.text = member.initials
        avatarView.backgroundColor = generateColor(from: member.fullName)
        
        // Configure status
        if let location = location {
            if location.isLive {
                statusLabel.text = "Location Live"
                statusIndicator.backgroundColor = .systemGreen
                statusIndicator.isHidden = false
            } else {
                statusLabel.text = "Offline"
                statusIndicator.backgroundColor = .systemGray
                statusIndicator.isHidden = true
            }
        } else {
            statusLabel.text = "No Location"
            statusIndicator.isHidden = true
        }
    }
    
    // MARK: - Helpers
    private func generateColor(from name: String) -> UIColor {
        // Generate a consistent color based on the name
        let colors: [UIColor] = [
            .systemOrange,
            .systemBlue,
            .systemGreen,
            .systemPink,
            .systemPurple,
            .systemTeal,
            .systemIndigo,
            .systemBrown
        ]
        
        let hash = name.hash
        let index = abs(hash) % colors.count
        return colors[index]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        statusLabel.text = nil
        avatarInitialsLabel.text = nil
        statusIndicator.isHidden = false
    }
}
