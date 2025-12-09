//
//  TripSubgroupTableViewCell.swift
//  TripSync
//
//  Created by Arpit Garg on 23/11/25.
//

import UIKit

class TripSubgroupCell: UITableViewCell {

    @IBOutlet weak var subgroupAvatarView: UIView!
    @IBOutlet weak var subgroupNameLabel: UILabel!
    @IBOutlet weak var subgroupDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func update(with subgroup: Subgroup) {
        subgroupAvatarView.backgroundColor = subgroup.color
        subgroupNameLabel.text = subgroup.name
        subgroupDescriptionLabel.text = subgroup.description
    }
}
