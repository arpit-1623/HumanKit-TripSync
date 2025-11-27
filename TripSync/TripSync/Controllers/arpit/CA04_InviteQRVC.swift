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
    var trip: Trip?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        generateQRCode()
    }
    
    // MARK: - Setup
    private func setupUI() {
        guard let trip = trip else { return }
        tripNameLabel.text = trip.name
        inviteCodeLabel.text = formatInviteCode(trip.inviteCode)
    }
    
    private func formatInviteCode(_ code: String) -> String {
        return code.map { String($0) }.joined(separator: " ")
    }
    
    private func generateQRCode() {
        guard let trip = trip else {
            showQRGenerationError("Trip data is missing")
            return
        }
        
        // Validate invite code format
        guard isValidInviteCode(trip.inviteCode) else {
            showQRGenerationError("Invalid invite code format")
            return
        }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            showQRGenerationError("QR code generator unavailable")
            return
        }
        
        guard let data = trip.inviteCode.data(using: .ascii) else {
            showQRGenerationError("Failed to encode invite code")
            return
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else {
            showQRGenerationError("Failed to generate QR code")
            return
        }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        qrCodeImageView.image = UIImage(ciImage: scaledImage)
    }
    
    // MARK: - Actions
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func copyCodeTapped(_ sender: UIButton) {
        guard let trip = trip else { return }
        UIPasteboard.general.string = trip.inviteCode
        
        // Show feedback
        let alert = UIAlertController(title: "Copied!", message: "Invite code copied to clipboard", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func shareInviteTapped(_ sender: UIButton) {
        guard let trip = trip else { return }
        let shareText = "Join my trip '\(trip.name)' on TripSync!\n\nInvite Code: \(trip.inviteCode)"
        
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
    
    // MARK: - Error Handling
    private func showErrorAndDismiss() {
        let alert = UIAlertController(
            title: "Error",
            message: "Unable to load trip invitation. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showQRGenerationError(_ message: String) {
        print("QR Generation Error: \(message)")
        // Set a placeholder or error state for the QR code image
        qrCodeImageView.image = UIImage(systemName: "exclamationmark.triangle")
        qrCodeImageView.tintColor = .systemRed
        
        let alert = UIAlertController(
            title: "QR Code Error",
            message: "Unable to generate QR code. \(message)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Validation
    private func isValidInviteCode(_ code: String) -> Bool {
        // Invite codes should be 8 alphanumeric characters
        let pattern = "^[A-Z0-9]{8}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: code.utf16.count)
        return regex?.firstMatch(in: code, range: range) != nil
    }
}
