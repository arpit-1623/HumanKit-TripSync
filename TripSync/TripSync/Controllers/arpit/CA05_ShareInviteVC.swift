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

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
