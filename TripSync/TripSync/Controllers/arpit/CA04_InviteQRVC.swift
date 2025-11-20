//
//  InviteQRViewController.swift
//  TripSync
//
//  Created by Arpit Garg on 20/11/25.
//

import UIKit

class InviteQRViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var inviteCodeLabel: UILabel!
    
    // MARK: - Properties
    var tripName: String = "Trip Name"
    var inviteCode: String = "CODE123"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateQRCode()
    }
    
    // MARK: - Setup
    private func setupUI() {
        tripNameLabel.text = tripName
        inviteCodeLabel.text = formatInviteCode(inviteCode)
    }
    
    private func formatInviteCode(_ code: String) -> String {
        return code.map { String($0) }.joined(separator: " ")
    }
    
    private func generateQRCode() {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return }
        let data = inviteCode.data(using: .ascii)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            qrCodeImageView.image = UIImage(ciImage: scaledImage)
        }
    }
    
    // MARK: - Actions
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func copyCodeTapped(_ sender: UIButton) {
        UIPasteboard.general.string = inviteCode
        
        // Show feedback
        let alert = UIAlertController(title: "Copied!", message: "Invite code copied to clipboard", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func shareInviteTapped(_ sender: UIButton) {
        let shareText = "Join my trip '\(tripName)' on TripSync!\n\nInvite Code: \(inviteCode)"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        present(activityVC, animated: true)
    }
}
