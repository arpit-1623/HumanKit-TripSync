//
//  ES03_SubgroupFilterCell.swift
//  TripSync
//
//  Created by Sajal Garg on 20/11/25.
//

import UIKit

class ES03_SubgroupFilterCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        // Container styling
        containerView.layer.cornerRadius = 25
        
        // Icon styling
        iconLabel.font = .systemFont(ofSize: 18)
        
        // Name label styling
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
    }
    
    // MARK: - Configuration
    func configure(name: String, colorHex: String, isSelected: Bool, showStar: Bool) {
        nameLabel.text = name
        iconLabel.text = showStar ? "⭐" : ""
        
        let color = UIColor(hex: colorHex) ?? .systemBlue
        
        if isSelected {
            containerView.backgroundColor = color
            nameLabel.textColor = .white
        } else {
            containerView.backgroundColor = UIColor.systemGray5
            nameLabel.textColor = .secondaryLabel
        }
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
