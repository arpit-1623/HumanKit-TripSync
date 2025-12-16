//
//  CS01_CreateAnnouncementVC.swift
//  TripSync
//
//  Created by Arpit Garg on 26/11/25.
//

import UIKit

class CreateAnnouncementViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var veryImportantView: UIView!
    @IBOutlet weak var importantView: UIView!
    @IBOutlet weak var generalView: UIView!
    @IBOutlet weak var veryImportantIcon: UIImageView!
    @IBOutlet weak var importantIcon: UIImageView!
    @IBOutlet weak var generalIcon: UIImageView!
    @IBOutlet weak var veryImportantLabel: UILabel!
    @IBOutlet weak var importantLabel: UILabel!
    @IBOutlet weak var generalLabel: UILabel!
    @IBOutlet weak var sendNotificationSwitch: UISwitch!
    
    // MARK: - Properties
    var trip: Trip?
    var onAnnouncementCreated: (() -> Void)?
    private var selectedPriority: AnnouncementPriority = .general
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Setup text view insets (not available in IB)
        messageTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        
        // Setup text field left view (for proper text alignment)
        titleTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        titleTextField.leftViewMode = .always
        
        // Select general by default
        updatePrioritySelection()
    }
    
    private func updatePrioritySelection() {
        // Reset all views to unselected state
        veryImportantView.backgroundColor = .systemGray6
        importantView.backgroundColor = .systemGray6
        generalView.backgroundColor = .systemGray6
        
        veryImportantIcon.tintColor = .systemGray
        importantIcon.tintColor = .systemGray
        generalIcon.tintColor = .systemGray
        
        veryImportantLabel.textColor = .systemGray
        importantLabel.textColor = .systemGray
        generalLabel.textColor = .systemGray
        
        // Highlight selected with bright background color
        switch selectedPriority {
        case .veryImportant:
            veryImportantView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            veryImportantIcon.tintColor = .systemRed
            veryImportantLabel.textColor = .systemRed
        case .important:
            importantView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.25)
            importantIcon.tintColor = .systemOrange
            importantLabel.textColor = .systemOrange
        case .general:
            generalView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
            generalIcon.tintColor = .systemBlue
            generalLabel.textColor = .systemBlue
        }
    }
    
    @IBAction private func veryImportantTapped(_ sender: Any) {
        selectedPriority = .veryImportant
        updatePrioritySelection()
    }
    
    @IBAction private func importantTapped(_ sender: Any) {
        selectedPriority = .important
        updatePrioritySelection()
    }
    
    @IBAction private func generalTapped(_ sender: Any) {
        selectedPriority = .general
        updatePrioritySelection()
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func sendTapped() {
        // Validate trip and user
        guard let trip = trip,
              let currentUser = DataModel.shared.getCurrentUser() else {
            return
        }
        
        // Validate title
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else {
            let alert = UIAlertController(title: "Missing Information", message: "Please fill in both title and message fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Validate message (check if it's not empty and not placeholder)
        let message = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isPlaceholder = messageTextView.textColor == .systemGray
        guard !message.isEmpty && !isPlaceholder else {
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
            isAnnouncement: true,
            priority: selectedPriority
        )
        announcement.announcementTitle = title
        announcement.sendNotification = sendNotificationSwitch.isOn
        
        DataModel.shared.saveMessage(announcement)
        
        // Dismiss view controller
        dismiss(animated: true) {
            self.onAnnouncementCreated?()
        }
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
