//
//  MemberProfileViewController.swift
//  TripSync
//
//  Created for issue #16 — replaces placeholder alert with a real member profile view.
//

import UIKit

class MemberProfileViewController: UIViewController {
    
    // MARK: - Properties
    var member: User?
    var trip: Trip?
    
    // MARK: - UI Elements
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let memberSinceLabel = UILabel()
    private let tripRoleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithMember()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Close button
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .secondaryLabel
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Profile image
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 44
        profileImageView.backgroundColor = .systemGray5
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        // Name label
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        // Email label
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        emailLabel.textColor = .secondaryLabel
        emailLabel.textAlignment = .center
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailLabel)
        
        // Trip role label
        tripRoleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        tripRoleLabel.textColor = .systemBlue
        tripRoleLabel.textAlignment = .center
        tripRoleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tripRoleLabel)
        
        // Member since label
        memberSinceLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        memberSinceLabel.textColor = .tertiaryLabel
        memberSinceLabel.textAlignment = .center
        memberSinceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(memberSinceLabel)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 88),
            profileImageView.heightAnchor.constraint(equalToConstant: 88),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tripRoleLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 12),
            tripRoleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tripRoleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            memberSinceLabel.topAnchor.constraint(equalTo: tripRoleLabel.bottomAnchor, constant: 8),
            memberSinceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            memberSinceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    // MARK: - Configuration
    private func configureWithMember() {
        guard let member = member else { return }
        
        nameLabel.text = member.fullName
        emailLabel.text = member.email
        
        // Profile image
        if let imageData = member.profileImage, let image = UIImage(data: imageData) {
            profileImageView.image = image
            profileImageView.backgroundColor = .clear
        } else {
            profileImageView.image = nil
            profileImageView.backgroundColor = generateColor(from: member.fullName)
            addInitialsLabel(with: member.initials)
        }
        
        // Trip role
        if let trip = trip {
            if trip.isUserAdmin(member.id) {
                tripRoleLabel.text = "Trip Admin"
            } else {
                tripRoleLabel.text = "Member"
            }
        }
        
        // Member since
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        memberSinceLabel.text = "Member since \(formatter.string(from: member.createdAt))"
    }
    
    // MARK: - Helpers
    private func addInitialsLabel(with initials: String) {
        let label = UILabel()
        label.text = initials
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    private func generateColor(from name: String) -> UIColor {
        let colors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange,
            .systemPink, .systemPurple, .systemTeal,
            .systemIndigo, .systemBrown
        ]
        let hash = name.hash
        let index = abs(hash) % colors.count
        return colors[index]
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
