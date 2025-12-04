//
//  GeneralChatVC.swift
//  TripSync
//
//  Created by Sajal Garg on 19/11/25.
//

import UIKit

class GeneralChatViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageInputBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var trip: Trip?
    private var messages: [Message] = []
    private var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadCurrentUser()
        loadMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMessages()
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func loadCurrentUser() {
        currentUser = DataModel.shared.getCurrentUser()
    }
    
    private func loadMessages() {
        guard let trip = trip else { return }
        
        // Load general messages (subgroupId is nil)
        messages = DataModel.shared.getMessages(forTripId: trip.id, subgroupId: nil)
        
        // Filter out announcements (they appear in Alerts tab)
        messages = messages.filter { !$0.isAnnouncement }
        
        tableView.reloadData()
        scrollToBottom()
    }
    
    private func scrollToBottom(animated: Bool = false) {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
    
    // MARK: - Keyboard Handling
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        // Convert keyboard frame to view's coordinate space
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let viewBottom = view.bounds.height
        
        // Calculate how much of the keyboard overlaps with the view
        let keyboardOverlap = max(0, viewBottom - keyboardFrameInView.origin.y)
        
        // Adjust constraint based on keyboard overlap
        messageInputBottomConstraint.constant = keyboardOverlap
        
        let animationCurve = UIView.AnimationCurve(rawValue: Int(curveValue)) ?? .easeInOut
        let animator = UIViewPropertyAnimator(duration: duration, curve: animationCurve) {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
        
        // Scroll to bottom after keyboard appears
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.scrollToBottom(animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        // Reset to original 0pt offset
        messageInputBottomConstraint.constant = 0
        
        let animationCurve = UIView.AnimationCurve(rawValue: Int(curveValue)) ?? .easeInOut
        let animator = UIViewPropertyAnimator(duration: duration, curve: animationCurve) {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    // MARK: - Actions
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let trip = trip,
              let currentUser = currentUser,
              let messageText = messageTextField.text,
              !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Create and save message
        let newMessage = Message(
            content: messageText,
            senderUserId: currentUser.id,
            tripId: trip.id,
            subgroupId: nil
        )
        
        DataModel.shared.saveMessage(newMessage)
        
        // Clear text field and dismiss keyboard
        messageTextField.text = ""
        messageTextField.resignFirstResponder()
        
        // Reload messages
        loadMessages()
    }
    
}

// MARK: - UITableViewDelegate & DataSource
extension GeneralChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let isOutgoing = message.senderUserId == currentUser?.id
        
        let identifier = isOutgoing ? "OutgoingMessageCell" : "IncomingMessageCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ChatTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: message, isOutgoing: isOutgoing)
        
        return cell
    }
    
}
