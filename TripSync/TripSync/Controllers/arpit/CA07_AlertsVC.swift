//
//  CS01_AlertsVC.swift
//  TripSync
//
//  Created by Arpit Garg on 26/11/25.
//

import UIKit

class AlertsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var emptyStateView: UIView?
    @IBOutlet weak var emptyStateImageView: UIImageView?
    @IBOutlet weak var emptyStateLabel: UILabel?
    @IBOutlet weak var createAnnouncementButton: UIButton?
    
    // MARK: - Properties
    var trip: Trip?
    private var announcements: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAnnouncements()
    }
    
    // MARK: - Setup
    private func setupUI() {
        emptyStateLabel?.text = "No Announcements"
        emptyStateLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel?.textColor = .systemGray
    }
    
    private func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAnnouncementTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func loadAnnouncements() {
        guard let trip = trip else { return }
        
        // Load all messages and filter for announcements
        let allMessages = DataModel.shared.getMessages(forTripId: trip.id, subgroupId: nil)
        announcements = allMessages.filter { $0.isAnnouncement }
        
        // Show/hide empty state
        emptyStateView?.isHidden = !announcements.isEmpty
        tableView?.isHidden = announcements.isEmpty
        
        tableView?.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addAnnouncementTapped() {
        performSegue(withIdentifier: "alertsToCreateAnnouncement", sender: nil)
    }
    
    @IBAction func createAnnouncementTapped() {
        performSegue(withIdentifier: "alertsToCreateAnnouncement", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "alertsToCreateAnnouncement" {
            if let navController = segue.destination as? UINavigationController,
               let destinationVC = navController.topViewController as? CreateAnnouncementViewController {
                destinationVC.trip = self.trip
                destinationVC.onAnnouncementCreated = { [weak self] in
                    self?.loadAnnouncements()
                }
            }
        }
    }
    
}

// MARK: - UITableViewDelegate & DataSource
extension AlertsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementCell", for: indexPath) as? AnnouncementCell else {
            return UITableViewCell()
        }
        
        let announcement = announcements[indexPath.row]
        cell.configure(with: announcement)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
