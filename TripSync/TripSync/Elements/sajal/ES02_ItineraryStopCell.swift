//
//  ES02_ItineraryStopCell.swift
//  TripSync
//
//  Created by Sajal Garg on 20/11/25.
//

import UIKit

class ES02_ItineraryStopCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var colorBarView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeIconImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subgroupPillView: UIView!
    @IBOutlet weak var subgroupLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Container view styling
        containerView.backgroundColor = UIColor(named: "CardColor") ?? .systemGray6
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        // Color bar
        colorBarView.layer.cornerRadius = 2
        
        // Icon styling
        iconImageView.tintColor = .systemOrange
        iconImageView.contentMode = .scaleAspectFit
        
        // Title label
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        
        // Location label
        locationLabel.font = .systemFont(ofSize: 14, weight: .regular)
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 1
        
        // Time icon
        timeIconImageView.image = UIImage(systemName: "clock")
        timeIconImageView.tintColor = .secondaryLabel
        timeIconImageView.contentMode = .scaleAspectFit
        
        // Time label
        timeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = .label
        
        // Subgroup pill
        subgroupPillView.layer.cornerRadius = 12
        subgroupLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subgroupLabel.textColor = .white
    }
    
    // MARK: - Configuration
    func configure(with stop: ItineraryStop, subgroup: Subgroup?, timeFormatter: DateFormatter, isViewingMyItinerary: Bool = false) {
        titleLabel.text = stop.title
        locationLabel.text = stop.location
        timeLabel.text = timeFormatter.string(from: stop.time)
        
        // Set icon based on current view context
        // Show heart icon ONLY when viewing MY itinerary filter
        // Show location pin icon when viewing ALL or specific subgroups
        if isViewingMyItinerary {
            iconImageView.image = UIImage(systemName: "heart.circle.fill")
            iconImageView.tintColor = .systemPink
        } else {
            iconImageView.image = UIImage(systemName: "mappin.circle.fill")
            iconImageView.tintColor = .systemOrange
        }
        
        // Configure color bar and subgroup pill with multiple tags
        var tags: [String] = []
        var primaryColor: UIColor = .systemBlue
        
        // Add MY tag if in MY itinerary
        if stop.isInMyItinerary {
            tags.append("MY")
            primaryColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1) // #FF2D55 pink
        }
        
        // Add subgroup tag if it belongs to a subgroup
        if let subgroup = subgroup {
            tags.append(subgroup.name)
            // If not in MY, use subgroup color as primary
            if !stop.isInMyItinerary {
                primaryColor = UIColor(hex: subgroup.colorHex) ?? .systemBlue
            }
        }
        
        // If no tags, show "All"
        if tags.isEmpty {
            tags.append("All")
            primaryColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) // #007AFF blue
        }
        
        // Set color bar to primary color
        colorBarView.backgroundColor = primaryColor
        
        // Display tags
        subgroupPillView.isHidden = false
        subgroupPillView.backgroundColor = primaryColor
        subgroupLabel.text = tags.joined(separator: " • ")
    }
}

// MARK: - UIColor Extension
//extension UIColor {
//    convenience init?(hex: String) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//        
//        var rgb: UInt64 = 0
//        
//        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
//        
//        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//        let blue = CGFloat(rgb & 0x0000FF) / 255.0
//        
//        self.init(red: red, green: green, blue: blue, alpha: 1.0)
//    }
//}

