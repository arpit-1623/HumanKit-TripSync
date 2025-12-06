//
//  ES06_AnnouncementCell.swift
//  TripSync
//
//  Created by GitHub Copilot on 26/11/25.
//

import UIKit

class AnnouncementCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        messageLabel.textColor = .systemGray
        messageLabel.numberOfLines = 2
        
        timestampLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        timestampLabel.textColor = .systemGray2
        
        selectionStyle = .none
    }
    
    func configure(with announcement: Message) {
        titleLabel.text = announcement.announcementTitle ?? "Announcement"
        messageLabel.text = announcement.content
        
        // Format timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        timestampLabel.text = formatter.string(from: announcement.timestamp)
        
        // Apply priority color
        let priorityColor = announcement.priority.color
        containerView.backgroundColor = priorityColor.withAlphaComponent(0.1)
        iconImageView.tintColor = priorityColor
        iconImageView.image = UIImage(systemName: announcement.priority.icon)
    }
    
}
