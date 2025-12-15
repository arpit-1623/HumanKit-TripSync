//
//  CS01_SubgroupsListVC.swift
//  TripSync
//
//  Created by Arpit Garg on 26/11/25.
//

import UIKit

class SubgroupsListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var trip: Trip?
    private var subgroups: [Subgroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadSubgroups()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSubgroups()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadSubgroups() {
        guard let trip = trip else { return }
        
        // Load all subgroups for this trip
        subgroups = trip.subgroupIds.compactMap { subgroupId in
            DataModel.shared.getSubgroup(byId: subgroupId)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subgroupsListToSubgroupChat",
           let destinationVC = segue.destination as? SubgroupChatViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            let selectedSubgroup = subgroups[indexPath.row]
            destinationVC.trip = self.trip
            destinationVC.subgroup = selectedSubgroup
        }
    }
    
}

// MARK: - UITableViewDelegate & DataSource
extension SubgroupsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subgroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subgroup = subgroups[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubgroupListCell", for: indexPath) as? SubgroupListCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: subgroup)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue is triggered automatically from storyboard cell connection
    }
    
}
