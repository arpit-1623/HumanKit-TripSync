//
//  ES05_StatCell.swift
//  TripSync
//
//  Created on 23/11/2025.
//

import UIKit

class StatCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
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
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 0
        
        // Configure value label
        valueLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = .systemBlue
        valueLabel.textAlignment = .center
        
        // Configure title label
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
    }
    
    // MARK: - Configuration
    func configure(value: Int, label: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = label
    }
    
    func configureHorizontal(trips: Int, memories: Int, photos: Int) {
        // Check if horizontal stack already exists
        if let existingStack = containerView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            // Update existing views
            if existingStack.arrangedSubviews.count == 3 {
                updateStatView(existingStack.arrangedSubviews[0], value: trips, label: "Trips")
                updateStatView(existingStack.arrangedSubviews[1], value: memories, label: "Memories")
                updateStatView(existingStack.arrangedSubviews[2], value: photos, label: "Photos")
                return
            }
        }
        
        // Remove existing subviews only if we need to create new layout
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Create horizontal stack with three stat views
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = 12
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Create three stat views
        let tripsStat = createStatView(value: trips, label: "Trips")
        let memoriesStat = createStatView(value: memories, label: "Memories")
        let photosStat = createStatView(value: photos, label: "Photos")
        
        horizontalStack.addArrangedSubview(tripsStat)
        horizontalStack.addArrangedSubview(memoriesStat)
        horizontalStack.addArrangedSubview(photosStat)
        
        containerView.addSubview(horizontalStack)
        
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            horizontalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            horizontalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            horizontalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    private func updateStatView(_ view: UIView, value: Int, label labelText: String) {
        // Find and update the labels in the existing view
        for subview in view.subviews {
            if let label = subview as? UILabel {
                if label.font.pointSize == 32 {
                    label.text = "\(value)"
                } else if label.font.pointSize == 14 {
                    label.text = labelText
                }
            }
        }
    }
    
    private func createStatView(value: Int, label: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        
        let valueLabel = UILabel()
        valueLabel.text = "\(value)"
        valueLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = .systemBlue
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        return container
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Don't remove subviews here as they will be reused
        // The configureHorizontal method handles updates
    }
}
