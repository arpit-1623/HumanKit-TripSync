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
    
    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
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
        
        // Clear text field
        messageTextField.text = ""
        
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
