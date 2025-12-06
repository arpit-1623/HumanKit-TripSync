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
    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeIconImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var myPillView: UIView!
    @IBOutlet weak var myLabel: UILabel!
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
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        
        // Location icon
        locationIconImageView.image = UIImage(systemName: "mappin")
        locationIconImageView.tintColor = .secondaryLabel
        locationIconImageView.contentMode = .scaleAspectFit
        
        // Location label
        locationLabel.font = .systemFont(ofSize: 14, weight: .regular)
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 1
        
        // Time icon (hidden in new layout)
        timeIconImageView.isHidden = true
        
        // Time label
        timeLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        timeLabel.textColor = .label
        timeLabel.textAlignment = .right
        
        // MY pill
        myPillView.layer.cornerRadius = 12
        myLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        myLabel.textColor = .white
        myLabel.text = "MY"
        
        // Subgroup pill
        subgroupPillView.layer.cornerRadius = 12
        subgroupLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        subgroupLabel.textColor = .white
    }
    
    // MARK: - Configuration
    func configure(with stop: ItineraryStop, subgroup: Subgroup?, timeFormatter: DateFormatter, isViewingMyItinerary: Bool = false) {
        // Limit title to 20 characters
        if stop.title.count > 20 {
            titleLabel.text = String(stop.title.prefix(20)) + "..."
        } else {
            titleLabel.text = stop.title
        }
        locationLabel.text = stop.location
        timeLabel.text = timeFormatter.string(from: stop.time)
        
        // Set icon based on category
        // If stop has a category, use that SF Symbol
        // Otherwise, show heart for MY itinerary view or default mappin
        if let category = stop.category {
            iconImageView.image = UIImage(systemName: category)
            iconImageView.tintColor = .systemOrange
        } else if isViewingMyItinerary {
            iconImageView.image = UIImage(systemName: "heart.circle.fill")
            iconImageView.tintColor = .systemPink
        } else {
            iconImageView.image = UIImage(systemName: "mappin.and.ellipse")
            iconImageView.tintColor = .systemOrange
        }
        
        // MY Pill Configuration
        let myPinkColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1) // #FF2D55
        if stop.isInMyItinerary {
            myPillView.isHidden = false
            myPillView.backgroundColor = myPinkColor
            myLabel.text = "MY"
            colorBarView.backgroundColor = myPinkColor
        } else {
            myPillView.isHidden = true
        }
        
        // Subgroup Pill Configuration
        if let subgroup = subgroup {
            // Show subgroup pill with subgroup name and color
            subgroupPillView.isHidden = false
            let subgroupColor = UIColor(hex: subgroup.colorHex) ?? .systemBlue
            subgroupPillView.backgroundColor = subgroupColor
            subgroupLabel.text = subgroup.name
            
            // If not in MY itinerary, use subgroup color for color bar
            if !stop.isInMyItinerary {
                colorBarView.backgroundColor = subgroupColor
            }
        } else {
            // Show "All" pill
            subgroupPillView.isHidden = false
            let allBlueColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) // #007AFF
            subgroupPillView.backgroundColor = allBlueColor
            subgroupLabel.text = "All"
            
            // If not in MY itinerary, use All blue color for color bar
            if !stop.isInMyItinerary {
                colorBarView.backgroundColor = allBlueColor
            }
        }
    }
}

