//
//  CS03_SubgroupDetailsVC.swift
//  TripSync
//
//  Created on 23/11/2025.
//

import UIKit

class SubgroupDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var itineraryButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var subgroup: Subgroup?
    var members: [User] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadData()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Subgroup Details"
        
        // Configure logo view
        logoView.layer.cornerRadius = 40 // 80pt diameter / 2
        logoView.layer.masksToBounds = true
        logoView.layer.shadowColor = UIColor.black.cgColor
        logoView.layer.shadowOpacity = 0.1
        logoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoView.layer.shadowRadius = 4
        
        // Configure logo label
        logoLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        logoLabel.textColor = .white
        logoLabel.textAlignment = .center
        
        // Configure name label
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .label
        
        // Configure description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        // Configure action buttons
        configureActionButton(itineraryButton, title: "Itinerary", icon: "list.bullet")
        configureActionButton(chatButton, title: "Chat", icon: "message.fill")
    }
    
    private func configureActionButton(_ button: UIButton, title: String, icon: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePadding = 8
        config.imagePlacement = .top
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        button.configuration = config
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
    }
    
    private func setupTableView() {
        membersTableView.delegate = self
        membersTableView.dataSource = self
        membersTableView.isScrollEnabled = false
        membersTableView.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0)
    }
    
    private func loadData() {
        guard let subgroup = subgroup else { return }
        
        // Set subgroup details
        nameLabel.text = subgroup.name
        descriptionLabel.text = subgroup.description
        
        // Set logo color
        if let color = UIColor(hex: subgroup.colorHex) {
            logoView.backgroundColor = color
        } else {
            logoView.backgroundColor = .systemBlue
        }
        
        // Set logo initial (first letter of name)
        if let firstLetter = subgroup.name.first {
            logoLabel.text = String(firstLetter).uppercased()
        }
        
        // Load members
        members = subgroup.memberIds.compactMap { memberId in
            DataModel.shared.getUser(byId: memberId)
        }
        
        membersTableView.reloadData()
        updateTableHeight()
    }
    
    private func updateTableHeight() {
        let rowHeight: CGFloat = 88
        let totalHeight = CGFloat(members.count) * rowHeight
        tableHeightConstraint.constant = totalHeight
    }
    
    // MARK: - Actions
    @IBAction func itineraryButtonTapped(_ sender: UIButton) {
        guard let subgroup = subgroup else { return }
        
        // Navigate to itinerary with subgroup filter
        performSegue(withIdentifier: "subgroupDetailsToItinerary", sender: subgroup)
    }
    
    @IBAction func chatButtonTapped(_ sender: UIButton) {
        guard let subgroup = subgroup else { return }
        
        // Navigate to chat with subgroup filter
        performSegue(withIdentifier: "subgroupDetailsToChat", sender: subgroup)
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        // Show invite options
        let alert = UIAlertController(title: "Invite Members", message: "Choose an invite method", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share QR Code", style: .default) { _ in
            self.showQRCode()
        })
        
        alert.addAction(UIAlertAction(title: "Share Link", style: .default) { _ in
            self.shareInviteLink()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showQRCode() {
        // TODO: Implement QR code display
        print("Show QR Code for subgroup invitation")
    }
    
    private func shareInviteLink() {
        guard let subgroup = subgroup else { return }
        
        let inviteText = "Join \(subgroup.name) on TripSync!"
        let activityVC = UIActivityViewController(activityItems: [inviteText], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subgroupDetailsToItinerary",
           let subgroup = sender as? Subgroup {
            // TODO: Pass subgroup filter to itinerary when view controller is ready
            print("Navigate to itinerary for subgroup: \(subgroup.name)")
        } else if segue.identifier == "subgroupDetailsToChat",
                  let subgroup = sender as? Subgroup {
            // TODO: Pass subgroup filter to chat when view controller is ready
            print("Navigate to chat for subgroup: \(subgroup.name)")
        }
    }
}

// MARK: - UITableViewDataSource
extension SubgroupDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as? MemberTableViewCell else {
            return UITableViewCell()
        }
        
        let member = members[indexPath.row]
        cell.configure(with: member, role: "Member")
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SubgroupDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Show member details if needed
    }
}
