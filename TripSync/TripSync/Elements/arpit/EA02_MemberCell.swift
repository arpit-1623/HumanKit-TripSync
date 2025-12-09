//
//  EA02_MemberCell.swift
//  TripSync
//
//  Created by Arpit Garg on 20/11/25.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var memberRoleLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    // MARK: - Properties
    var menuButtonTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure profile image view
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 32
        profileImageView.backgroundColor = .systemGray5
        
        // Configure menu button
        menuButton?.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(with user: User, role: String) {
        memberNameLabel.text = user.fullName
        memberRoleLabel.text = role
        
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
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
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
    
    // MARK: - Actions
    @objc private func menuButtonPressed() {
        menuButtonTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        profileImageView.subviews.forEach { $0.removeFromSuperview() }
        memberNameLabel.text = nil
        memberRoleLabel.text = nil
        menuButtonTapped = nil
    }
}
