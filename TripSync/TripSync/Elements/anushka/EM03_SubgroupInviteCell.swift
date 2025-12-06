//
//  EM03_SubgroupInviteCell.swift
//  TripSync
//
//  Created by GitHub Copilot on 06/12/25.
//

import UIKit

class SubgroupInviteCell: UITableViewCell {
    
    // MARK: - Properties
    private var onAccept: (() -> Void)?
    private var onDecline: (() -> Void)?
    private var onViewDetails: (() -> Void)?
    
    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 35
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.2.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let inviterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let inviterDetailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let membersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let membersDetailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("  Accept Invitation", for: .normal)
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let detailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Details", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Decline", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        
        iconView.addSubview(iconImageView)
        cardView.addSubview(iconView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(timeLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(inviterLabel)
        cardView.addSubview(inviterDetailLabel)
        cardView.addSubview(membersLabel)
        cardView.addSubview(membersDetailLabel)
        cardView.addSubview(acceptButton)
        cardView.addSubview(detailsButton)
        cardView.addSubview(declineButton)
        
        NSLayoutConstraint.activate([
            // Card view
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Icon view
            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 70),
            iconView.heightAnchor.constraint(equalToConstant: 70),
            
            // Icon image
            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            // Time
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Message
            messageLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor),
            
            // Inviter label
            inviterLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            inviterLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            
            // Inviter detail
            inviterDetailLabel.topAnchor.constraint(equalTo: inviterLabel.bottomAnchor, constant: 4),
            inviterDetailLabel.leadingAnchor.constraint(equalTo: inviterLabel.leadingAnchor),
            
            // Members label
            membersLabel.topAnchor.constraint(equalTo: inviterLabel.topAnchor),
            membersLabel.leadingAnchor.constraint(equalTo: cardView.centerXAnchor, constant: 10),
            
            // Members detail
            membersDetailLabel.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: 4),
            membersDetailLabel.leadingAnchor.constraint(equalTo: membersLabel.leadingAnchor),
            
            // Accept button
            acceptButton.topAnchor.constraint(equalTo: inviterDetailLabel.bottomAnchor, constant: 20),
            acceptButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            acceptButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            acceptButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Details button
            detailsButton.topAnchor.constraint(equalTo: acceptButton.bottomAnchor, constant: 16),
            detailsButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            detailsButton.heightAnchor.constraint(equalToConstant: 50),
            detailsButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            
            // Decline button
            declineButton.topAnchor.constraint(equalTo: detailsButton.topAnchor),
            declineButton.leadingAnchor.constraint(equalTo: detailsButton.trailingAnchor, constant: 16),
            declineButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            declineButton.heightAnchor.constraint(equalToConstant: 50),
            declineButton.widthAnchor.constraint(equalTo: detailsButton.widthAnchor)
        ])
        
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
