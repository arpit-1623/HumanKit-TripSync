//
//  CS01_SubgroupChatVC.swift
//  TripSync
//
//  Created by GitHub Copilot on 26/11/25.
//

import UIKit

class SubgroupChatViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageInputBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var trip: Trip?
    var subgroup: Subgroup?
    private var messages: [Message] = []
    private var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
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
    private func setupNavigationTitle() {
        title = subgroup?.name ?? "Subgroup Chat"
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    private func loadCurrentUser() {
        currentUser = DataModel.shared.getCurrentUser()
    }
    
    private func loadMessages() {
        guard let trip = trip, let subgroup = subgroup else { return }
        
        // Load messages for this specific subgroup
        messages = DataModel.shared.getMessages(forTripId: trip.id, subgroupId: subgroup.id)
        
        // Filter out announcements
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
        
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        // Adjust constraint: keyboard height minus safe area (to avoid double counting)
        messageInputBottomConstraint.constant = keyboardHeight - safeAreaBottom
        
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
        
        // Reset to original 15pt offset
        messageInputBottomConstraint.constant = 15
        
        let animationCurve = UIView.AnimationCurve(rawValue: Int(curveValue)) ?? .easeInOut
        let animator = UIViewPropertyAnimator(duration: duration, curve: animationCurve) {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    // MARK: - Actions
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let trip = trip,
              let subgroup = subgroup,
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
            subgroupId: subgroup.id
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
extension SubgroupChatViewController: UITableViewDelegate, UITableViewDataSource {
    
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
