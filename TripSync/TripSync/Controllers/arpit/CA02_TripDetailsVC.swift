//
//  CA02_TripDetailsVC.swift
//  TripSync
//
//  Created on 19/11/2025.
//

import UIKit

class TripDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Menu Actions
    
    @IBAction func shareInviteTapped(_ sender: Any) {
        // TODO: Implement share invite functionality
        // This should present UIActivityViewController with trip invite
        let alert = UIAlertController(title: "Share Invite", message: "Share trip invite functionality will be implemented here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func showQRTapped(_ sender: Any) {
        // TODO: Implement QR code display
        // This should present a modal with generated QR code for the trip
        // let alert = UIAlertController(title: "Show QR", message: "QR code display functionality will be implemented here", preferredStyle: .alert)
        // alert.addAction(UIAlertAction(title: "OK", style: .default))
        // present(alert, animated: true)
        
        performSegue(withIdentifier: "tripDetailsToInviteQR", sender: nil)
    }
    
    @IBAction func editTripTapped(_ sender: Any) {
        // TODO: Implement edit trip functionality
        // This should navigate to edit trip screen
        // let alert = UIAlertController(title: "Edit Trip", message: "Edit trip functionality will be implemented here", preferredStyle: .alert)
        // alert.addAction(UIAlertAction(title: "OK", style: .default))
        // present(alert, animated: true)
        
        performSegue(withIdentifier: "tripDetailsToEditTrip", sender: nil)
    }
    
    // MARK: - Button Actions
    
    @IBAction func mapButtonTapped(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(
            title: "Map",
            message: "Map view will be shown here",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func chatButtonTapped(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(
            title: "Chat",
            message: "Group chat will open here",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func itineraryButtonTapped(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(
            title: "Itinerary",
            message: "Trip itinerary will be shown here",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func membersButtonTapped(_ sender: UITapGestureRecognizer) {
        // Navigate to members screen
        performSegue(withIdentifier: "tripDetailsToMembers", sender: nil)
    }
}
