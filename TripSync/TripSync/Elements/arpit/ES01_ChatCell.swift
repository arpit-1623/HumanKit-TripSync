//
//  ChatTableViewCell.swift
//  TripSync
//
//  Created by Arpit Garg on 19/11/25.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        
        // Setup avatar
        avatarImageView?.layer.cornerRadius = 16
        avatarImageView?.layer.masksToBounds = true
        avatarImageView?.contentMode = .scaleAspectFill
        
        // Setup bubble - simple rounded corners
        bubbleView.layer.cornerRadius = 18
        bubbleView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // No custom masking needed
    }
    
    func configure(with message: Message, isOutgoing: Bool) {
        messageLabel.text = message.content
        timestampLabel?.text = formatTimestamp(message.timestamp)
        
        if isOutgoing {
            nameLabel?.text = "You"
            avatarImageView?.isHidden = true
            
            // Rounded corners for outgoing (tail on bottom-right)
            bubbleView.layer.cornerRadius = 18
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        } else {
            // Get sender's info
            if let sender = DataModel.shared.getUser(byId: message.senderUserId) {
                nameLabel?.text = sender.fullName
                
                // Set avatar from profileImage or create initials avatar
                if let imageData = sender.profileImage, let image = UIImage(data: imageData) {
                    avatarImageView?.image = image
                } else {
                    // Create initials avatar
                    avatarImageView?.image = createInitialsAvatar(for: sender.initials)
                }
                avatarImageView?.isHidden = false
            } else {
                nameLabel?.text = "Unknown"
                avatarImageView?.image = createInitialsAvatar(for: "?")
                avatarImageView?.isHidden = false
            }
            
            // Rounded corners for incoming (tail on top-left)
            bubbleView.layer.cornerRadius = 18
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let minutes = components.minute, minutes < 1 {
            return "Just now"
        } else if let minutes = components.minute, minutes < 60 {
            return "\(minutes)m ago"
        } else if let hours = components.hour, hours < 24, calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "Yesterday " + formatter.string(from: date)
        } else if let days = components.day, days < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "E HH:mm"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, HH:mm"
            return formatter.string(from: date)
        }
    }
    
    private func createInitialsAvatar(for name: String) -> UIImage? {
        let initials = name.components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
        
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            UIColor.systemGray4.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            
            let textSize = (initials as NSString).size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            (initials as NSString).draw(in: textRect, withAttributes: attributes)
        }
    }
    
    func dummy(_ name: String, _ message: String) {
        nameLabel?.text = name
        messageLabel.text = message
        timestampLabel?.text = "Just now"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
