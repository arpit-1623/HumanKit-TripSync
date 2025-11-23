//
//  ES07_ActionCell.swift
//  TripSync
//
//  Created on 23/11/2025.
//

import UIKit

class ActionCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .default
        backgroundColor = .systemBackground
        
        // Configure icon label for SF Symbols
        iconLabel.font = UIFont.systemFont(ofSize: 20)
        
        // Configure title label
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        // Configure chevron
        chevronImageView.tintColor = .tertiaryLabel
        chevronImageView.image = UIImage(systemName: "chevron.right")
    }
    
    // MARK: - Configuration
    func configure(title: String, icon: String, isDestructive: Bool) {
        // Convert iconLabel to show SF Symbol
        iconLabel.text = ""
        if let image = UIImage(systemName: icon) {
            let tintColor: UIColor = isDestructive ? .systemRed : .systemBlue
            let attachment = NSTextAttachment()
            attachment.image = image.withTintColor(tintColor, renderingMode: .alwaysOriginal)
            let attachmentString = NSAttributedString(attachment: attachment)
            iconLabel.attributedText = attachmentString
        }
        titleLabel.text = title
        
        if isDestructive {
            titleLabel.textColor = .systemRed
            chevronImageView.isHidden = true
        } else {
            titleLabel.textColor = .label
            chevronImageView.isHidden = false
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconLabel.text = nil
        titleLabel.text = nil
        titleLabel.textColor = .label
        chevronImageView.isHidden = false
    }
}
