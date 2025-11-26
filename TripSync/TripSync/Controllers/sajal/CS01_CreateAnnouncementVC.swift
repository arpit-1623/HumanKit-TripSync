//
//  CS01_CreateAnnouncementVC.swift
//  TripSync
//
//  Created by GitHub Copilot on 26/11/25.
//

import UIKit

class CreateAnnouncementViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendNotificationSwitch: UISwitch!
    @IBOutlet weak var notificationDescriptionLabel: UILabel!
    
    // MARK: - Properties
    var trip: Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Setup text view border
        messageTextView.layer.borderColor = UIColor.systemGray4.cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.cornerRadius = 8
        messageTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        
        // Setup text field
        titleTextField.placeholder = "Announcement title"
        titleTextField.borderStyle = .roundedRect
        
        // Setup switch
        sendNotificationSwitch.isOn = true
        
        // Setup description label
        notificationDescriptionLabel.text = "Announcements will appear at the top of the homepage for all members"
        notificationDescriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        notificationDescriptionLabel.textColor = .systemGray
        notificationDescriptionLabel.numberOfLines = 0
    }
    
    private func setupNavigationBar() {
        title = "Announcement"
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        let sendButton = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendTapped))
        navigationItem.rightBarButtonItem = sendButton
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func sendTapped() {
        guard let trip = trip,
              let currentUser = DataModel.shared.getCurrentUser(),
              let title = titleTextField.text,
              !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let message = messageTextView.text,
              !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            
            // Show alert if fields are empty
            let alert = UIAlertController(title: "Missing Information", message: "Please fill in both title and message fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Create announcement
        var announcement = Message(
            content: message,
            senderUserId: currentUser.id,
            tripId: trip.id,
            subgroupId: nil,
            isAnnouncement: true
        )
        announcement.announcementTitle = title
        announcement.sendNotification = sendNotificationSwitch.isOn
        
        DataModel.shared.saveMessage(announcement)
        
        // Dismiss view controller
        dismiss(animated: true)
    }
    
}

// MARK: - UITextViewDelegate
extension CreateAnnouncementViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.systemGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your announcement message..."
            textView.textColor = UIColor.systemGray
        }
    }
    
}
