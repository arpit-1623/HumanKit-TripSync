//
//  ChatTableViewCell.swift
//  TripSync
//
//  Created by Sajal Garg on 19/11/25.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    func dummy(_ name: String, _ message: String) {
        nameLabel.text = name
        messageLabel.text = message
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
