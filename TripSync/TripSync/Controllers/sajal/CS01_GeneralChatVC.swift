//
//  GeneralChatVC.swift
//  TripSync
//
//  Created by Sajal Garg on 19/11/25.
//

import UIKit

class GeneralChatViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var trip: Trip?
    
    struct ChatMessage {
        let name: String
        let message: String
        let isOutgoing: Bool
    }
    
    private var messages: [ChatMessage] = [
        ChatMessage(name: "Alice", message: "Hey everyone! So excited for this trip!", isOutgoing: false),
        ChatMessage(name: "You", message: "Me too! Can't wait to explore Tokyo together.", isOutgoing: true),
        ChatMessage(name: "Bob", message: "I've made a list of must-visit temples!", isOutgoing: false),
        ChatMessage(name: "You", message: "That sounds great! Please share it.", isOutgoing: true),
        ChatMessage(name: "Charlie", message: "What about food recommendations?", isOutgoing: false),
        ChatMessage(name: "Alice", message: "I know some amazing ramen places!", isOutgoing: false),
        ChatMessage(name: "You", message: "Perfect! Let's make a list.", isOutgoing: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("Segment changed to: \(sender.selectedSegmentIndex)")
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
    }
    
}

// MARK: - UITableViewDelegate & DataSource
extension GeneralChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let identifier = message.isOutgoing ? "OutgoingMessageCell" : "IncomingMessageCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ChatTableViewCell else {
            return UITableViewCell()
        }
        
        // Use the dummy function
        cell.dummy(message.name, message.message)
        
        // Add rounded corners to bubble
        cell.bubbleView.layer.cornerRadius = 12
        cell.bubbleView.layer.masksToBounds = true
        
        return cell
    }
    
}
