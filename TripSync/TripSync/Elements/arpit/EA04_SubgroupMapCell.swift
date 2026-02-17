//
//  EA04_SubgroupMapCell.swift
//  TripSync
//
//  Created by Arpit Garg on 21/11/25.
//

import UIKit

protocol SubgroupMapCellDelegate: AnyObject {
    func didTapSubgroup(_ subgroup: Subgroup, cell: SubgroupMapCell)
}

class SubgroupMapCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var tapButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: SubgroupMapCellDelegate?
    private var subgroup: Subgroup?
    
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
        self.subgroup = subgroup
        nameLabel.text = subgroup.name
        detailLabel.text = "\(subgroup.memberIds.count) Members"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        detailLabel.text = nil
        subgroup = nil
    }
    
    // MARK: - Actions
    @IBAction func tapButtonTapped(_ sender: UIButton) {
        guard let subgroup = subgroup else { return }
        delegate?.didTapSubgroup(subgroup, cell: self)
    }
}
