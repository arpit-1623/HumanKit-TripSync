//
//  EM03_SubgroupInviteCell.swift
//  TripSync
//
//  Created by GitHub Copilot on 06/12/25.
//

import UIKit

class SubgroupInviteCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var inviterLabel: UILabel!
    @IBOutlet weak var inviterDetailLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var membersDetailLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    // MARK: - Properties
    private var onAccept: (() -> Void)?
    private var onDecline: (() -> Void)?
    private var onViewDetails: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyling()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupStyling() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Card view styling
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Icon view styling (circular)
        iconView.layer.cornerRadius = 35
        
        // Button corner radius
        acceptButton.layer.cornerRadius = 12
        detailsButton.layer.cornerRadius = 12
        declineButton.layer.cornerRadius = 12
    }
    
    private func setupActions() {
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)
        detailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(with invitation: Invitation, onAccept: @escaping () -> Void, onDecline: @escaping () -> Void, onViewDetails: @escaping () -> Void) {
        self.onAccept = onAccept
        self.onDecline = onDecline
        self.onViewDetails = onViewDetails
        
        // Get subgroup details
        if let subgroupId = invitation.subgroupId,
           let subgroup = DataModel.shared.getSubgroup(byId: subgroupId) {
            
            titleLabel.text = subgroup.name
            messageLabel.text = "You've been invited to join a subgroup!"
            descriptionLabel.text = subgroup.description ?? "No description provided"
            
            iconView.backgroundColor = subgroup.color
            
            // Get inviter details
            if let inviter = DataModel.shared.getUser(byId: invitation.invitedByUserId) {
                inviterLabel.text = inviter.fullName
                inviterDetailLabel.text = "Invited by"
            }
            
            // Members count
            membersLabel.text = "\(subgroup.memberIds.count)"
            membersDetailLabel.text = "Members"
        }
        
        // Time ago
        timeLabel.text = timeAgoString(from: invitation.createdAt)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day) day\(day == 1 ? "" : "s") ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
    
    // MARK: - Actions
    @objc private func acceptTapped() {
        onAccept?()
    }
    
    @objc private func declineTapped() {
        onDecline?()
    }
    
    @objc private func detailsTapped() {
        onViewDetails?()
    }
}
