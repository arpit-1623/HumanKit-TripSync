//
//  ES04_ProfileHeaderCell.swift
//  TripSync
//
//  Created on 23/11/2025.
//

import UIKit

class ProfileHeaderCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Configure container view
        containerView.backgroundColor = .secondarySystemGroupedBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.0
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowRadius = 0
        
        // Configure profile image view
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 32
        profileImageView.backgroundColor = .systemGray5
        
        // Configure name label
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label
    }
    
    // MARK: - Configuration
    func configure(with user: User) {
        nameLabel.text = user.fullName
        
        // Load profile image if available
        if let imageData = user.profileImage, let image = UIImage(data: imageData) {
            profileImageView.image = image
            profileImageView.backgroundColor = .clear
        } else {
            // Show initials with colored background
            profileImageView.image = nil
            profileImageView.backgroundColor = generateColor(from: user.fullName)
            addInitialsLabel(with: user.initials)
        }
    }
    
    // MARK: - Helpers
    private func addInitialsLabel(with initials: String) {
        // Remove existing initials label if any
        profileImageView.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.text = initials
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    private func generateColor(from name: String) -> UIColor {
        // Generate a consistent color based on the name
        let colors: [UIColor] = [
            .systemBlue,
            .systemGreen,
            .systemOrange,
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
        profileImageView.image = nil
        profileImageView.subviews.forEach { $0.removeFromSuperview() }
        nameLabel.text = nil
    }
}
