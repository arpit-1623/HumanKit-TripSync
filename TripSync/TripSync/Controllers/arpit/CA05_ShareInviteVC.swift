//
//  ShareInviteViewController.swift
//  TripSync
//
//  Created by Arpit Garg on 07/12/25.
//

import UIKit

class ShareInviteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func configureActivityVC(trip: Trip?) -> UIActivityViewController {
        guard let trip = trip else {
            return UIActivityViewController(activityItems: [], applicationActivities: nil)
        }
        
        let shareText = "Join my trip '\(trip.name)' on TripSync!\n\nInvite Code: \(trip.inviteCode)"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        return activityVC
    }
}
