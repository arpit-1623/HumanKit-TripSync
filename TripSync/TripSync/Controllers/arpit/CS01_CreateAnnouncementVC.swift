//
//  CS01_CreateAnnouncementVC.swift
//  TripSync
//
//  Created by GitHub Copilot on 26/11/25.
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
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Setup text view border
        messageTextView.layer.borderColor = UIColor.systemGray4.cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.cornerRadius = 8
        messageTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        messageTextView.delegate = self
        messageTextView.text = "Write your announcement message..."
        messageTextView.textColor = .systemGray
        
        // Setup text field
        titleTextField.placeholder = "Announcement title"
        titleTextField.layer.cornerRadius = 8
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.systemGray4.cgColor
        titleTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        titleTextField.leftViewMode = .always
        
        // Setup priority views
        setupPriorityView(veryImportantView, color: .systemRed, icon: veryImportantIcon, label: veryImportantLabel, iconName: "exclamationmark.3", text: "Very Important")
        setupPriorityView(importantView, color: .systemYellow, icon: importantIcon, label: importantLabel, iconName: "exclamationmark.2", text: "Important")
        setupPriorityView(generalView, color: .systemBlue, icon: generalIcon, label: generalLabel, iconName: "info.circle.fill", text: "General")
        
        // Add tap gestures
        veryImportantView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(veryImportantTapped)))
        importantView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(importantTapped)))
        generalView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(generalTapped)))
        
        // Select general by default
        updatePrioritySelection()
        
        // Setup switch
        sendNotificationSwitch.isOn = true
    }
    
    private func setupPriorityView(_ view: UIView, color: UIColor, icon: UIImageView, label: UILabel, iconName: String, text: String) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.backgroundColor = color.withAlphaComponent(0.1)
        
        icon.image = UIImage(systemName: iconName)
        icon.tintColor = color
        icon.contentMode = .scaleAspectFit
        
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = color
        label.textAlignment = .center
    }
    
    private func updatePrioritySelection() {
        // Reset all views
        veryImportantView.layer.borderColor = UIColor.systemGray5.cgColor
        importantView.layer.borderColor = UIColor.systemGray5.cgColor
        generalView.layer.borderColor = UIColor.systemGray5.cgColor
        
        veryImportantView.alpha = 0.5
        importantView.alpha = 0.5
        generalView.alpha = 0.5
        
        // Highlight selected
        switch selectedPriority {
        case .veryImportant:
            veryImportantView.layer.borderColor = UIColor.systemRed.cgColor
            veryImportantView.alpha = 1.0
        case .important:
            importantView.layer.borderColor = UIColor.systemYellow.cgColor
            importantView.alpha = 1.0
        case .general:
            generalView.layer.borderColor = UIColor.systemBlue.cgColor
            generalView.alpha = 1.0
        }
    }
    
    @objc private func veryImportantTapped() {
        selectedPriority = .veryImportant
        updatePrioritySelection()
    }
    
    @objc private func importantTapped() {
        selectedPriority = .important
        updatePrioritySelection()
    }
    
    @objc private func generalTapped() {
        selectedPriority = .general
        updatePrioritySelection()
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
        
        print("🚨 Saving announcement: \(announcement)")
        print("🚨 Trip ID: \(trip.id)")
        print("🚨 Is Announcement: \(announcement.isAnnouncement)")
        
        DataModel.shared.saveMessage(announcement)
        
        print("🚨 Message saved. Total messages: \(DataModel.shared.getAllMessages().count)")
        
        // Dismiss view controller
        dismiss(animated: true) {
            print("🚨 View controller dismissed")
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
