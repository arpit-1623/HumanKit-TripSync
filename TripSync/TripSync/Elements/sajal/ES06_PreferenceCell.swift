//
//  ES06_PreferenceCell.swift
//  TripSync
//
//  Created on 23/11/2025.
//

import UIKit

class PreferenceCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var chevronImageView: UIImageView!
    
    // MARK: - Properties
    var toggleChanged: ((Bool) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .default
        backgroundColor = .secondarySystemGroupedBackground
        
        // Configure icon as image view (will be set in configure method)
        iconLabel.font = UIFont.systemFont(ofSize: 20)
        
        // Configure title label
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .label
        
        // Configure subtitle label
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        
        // Configure toggle switch
        toggleSwitch.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
        
        // Configure chevron
        chevronImageView.tintColor = .tertiaryLabel
        chevronImageView.image = UIImage(systemName: "chevron.right")
    }
    
    // MARK: - Configuration
    func configure(title: String, icon: String, hasToggle: Bool, isToggleOn: Bool = false, subtitle: String? = nil) {
        // Convert iconLabel to show SF Symbol
        iconLabel.text = ""
        if let image = UIImage(systemName: icon) {
            let attachment = NSTextAttachment()
            attachment.image = image.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            let attachmentString = NSAttributedString(attachment: attachment)
            iconLabel.attributedText = attachmentString
        }
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        
        if hasToggle {
            toggleSwitch.isHidden = false
            toggleSwitch.isOn = isToggleOn
            chevronImageView.isHidden = true
            selectionStyle = .none
        } else {
            toggleSwitch.isHidden = true
            chevronImageView.isHidden = false
            selectionStyle = .default
        }
    }
    
    // MARK: - Actions
    @objc private func toggleValueChanged(_ sender: UISwitch) {
        toggleChanged?(sender.isOn)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconLabel.text = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        toggleSwitch.isOn = false
        toggleChanged = nil
    }
}
