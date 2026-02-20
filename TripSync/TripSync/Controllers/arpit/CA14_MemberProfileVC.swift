//
//  MemberProfileViewController.swift
//  TripSync
//
//  Created for issue #16 — replaces placeholder alert with a real member profile view.
//  UI is defined in SA14_MemberProfile.storyboard.
//

import UIKit

class MemberProfileViewController: UIViewController {
    
    // MARK: - Properties
    var member: User?
    var trip: Trip?
    
    // MARK: - Outlets (connected in SA14_MemberProfile.storyboard)
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var memberSinceLabel: UILabel!
    @IBOutlet weak var tripRoleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWithMember()
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
    @IBAction func closeTapped() {
        dismiss(animated: true)
    }
}
