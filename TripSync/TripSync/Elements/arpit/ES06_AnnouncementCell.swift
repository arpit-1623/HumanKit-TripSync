//
//  ES06_AnnouncementCell.swift
//  TripSync
//
//  Created by Arpit Garg on 26/11/25.
//

import UIKit

class AnnouncementCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyling()
    }
    
    // MARK: - Setup
    private func setupStyling() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Container view styling
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
    }
    
    func configure(with announcement: Message) {
        titleLabel.text = announcement.announcementTitle ?? "Announcement"
        messageLabel.text = announcement.content
        
        // Format timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        timestampLabel.text = formatter.string(from: announcement.timestamp)
        
        // Apply priority color with bolder background
        let priorityColor = announcement.priority.color
        containerView.backgroundColor = priorityColor.withAlphaComponent(0.2)
        iconImageView.tintColor = priorityColor
        iconImageView.image = UIImage(systemName: announcement.priority.icon)
    }
    
}
