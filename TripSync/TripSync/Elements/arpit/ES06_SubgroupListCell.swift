//
//  ES06_SubgroupListCell.swift
//  TripSync
//
//  Created by GitHub Copilot on 26/11/25.
//

import UIKit

class SubgroupListCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var colorIndicatorView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        colorIndicatorView.layer.cornerRadius = 8
        colorIndicatorView.layer.masksToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    func configure(with subgroup: Subgroup) {
        nameLabel.text = subgroup.name
        descriptionLabel.text = subgroup.description
        memberCountLabel.text = "\(subgroup.memberIds.count) members"
        colorIndicatorView.backgroundColor = subgroup.color
    }
    
}
