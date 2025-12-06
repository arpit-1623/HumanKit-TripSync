//
//  EA04_SubgroupMapCell.swift
//  TripSync
//
//  Created by Arpit Garg on 21/11/25.
//

import UIKit

class SubgroupMapCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // All styling is now in storyboard
        // backgroundColor, selectionStyle, and accessoryType are set in storyboard
    }
    
    // MARK: - Configuration
    func configure(with subgroup: Subgroup) {
        nameLabel.text = subgroup.name
        detailLabel.text = "\(subgroup.memberIds.count) Members"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        detailLabel.text = nil
    }
}
