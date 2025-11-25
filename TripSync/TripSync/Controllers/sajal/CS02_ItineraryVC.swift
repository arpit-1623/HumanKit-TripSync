//
//  CS02_ItineraryVC.swift
//  TripSync
//
//  Created by Sajal Garg on 20/11/25.
//

import UIKit

class CS02_ItineraryVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var subgroupCollectionView: UICollectionView!
    @IBOutlet weak var itineraryTableView: UITableView!
    
    // MARK: - Properties
    var trip: Trip?
    var allItineraryStops: [ItineraryStop] = []
    var groupedStops: [(date: Date, stops: [ItineraryStop])] = []
    var subgroups: [Subgroup] = []
    var selectedSubgroupId: UUID? = nil // nil means "All"
    
    // Date formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadTripData()
        setupCollectionView()
        setupTableView()
        filterAndGroupStops()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload data in case itinerary was modified
        loadTripData()
        filterAndGroupStops()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Itinerary"
        
        // Add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        view.backgroundColor = .systemBackground
    }
    
    private func setupCollectionView() {
        subgroupCollectionView.delegate = self
        subgroupCollectionView.dataSource = self
        subgroupCollectionView.showsHorizontalScrollIndicator = false
        subgroupCollectionView.backgroundColor = .clear
        
        if let layout = subgroupCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    private func setupTableView() {
        itineraryTableView.delegate = self
        itineraryTableView.dataSource = self
        itineraryTableView.separatorStyle = .none
        itineraryTableView.backgroundColor = .systemBackground
        itineraryTableView.rowHeight = UITableView.automaticDimension
        itineraryTableView.estimatedRowHeight = 120
        itineraryTableView.contentInsetAdjustmentBehavior = .never
        itineraryTableView.clipsToBounds = true
    }
    
    private func loadTripData() {
        guard let trip = trip else { return }
        
        // Load subgroups for this trip
        subgroups = DataModel.shared.getSubgroups(forTripId: trip.id)
        
        // Load itinerary stops for this trip
        allItineraryStops = DataModel.shared.getItineraryStops(forTripId: trip.id)
    }
    
    private func filterAndGroupStops() {
        // Filter by selected subgroup
        var filteredStops = allItineraryStops
        
        if let selectedId = selectedSubgroupId {
            filteredStops = allItineraryStops.filter { $0.subgroupId == selectedId }
        }
        
        // Group by date
        let calendar = Calendar.current
        var grouped: [Date: [ItineraryStop]] = [:]
        
        for stop in filteredStops {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: stop.date)
            if let normalizedDate = calendar.date(from: dateComponents) {
                if grouped[normalizedDate] == nil {
                    grouped[normalizedDate] = []
                }
                grouped[normalizedDate]?.append(stop)
            }
        }
        
        // Convert to sorted array
        groupedStops = grouped.map { (date: $0.key, stops: $0.value.sorted { $0.time < $1.time }) }
            .sorted { $0.date < $1.date }
        
        itineraryTableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        performSegue(withIdentifier: "showAddStop", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddStop" {
            if let navController = segue.destination as? UINavigationController,
               let addStopVC = navController.topViewController as? CS03_AddItineraryStopVC {
                addStopVC.delegate = self
                addStopVC.tripId = trip?.id
                addStopVC.availableSubgroups = subgroups
            }
        } else if segue.identifier == "showEditStop" {
            if let navController = segue.destination as? UINavigationController,
               let addStopVC = navController.topViewController as? CS03_AddItineraryStopVC,
               let indexPath = sender as? IndexPath {
                let stop = groupedStops[indexPath.section].stops[indexPath.row]
                addStopVC.delegate = self
                addStopVC.tripId = trip?.id
                addStopVC.availableSubgroups = subgroups
                addStopVC.existingStop = stop
            }
        }
    }
}

// MARK: - AddItineraryStopDelegate
extension CS02_ItineraryVC: AddItineraryStopDelegate {
    func didAddItineraryStop(_ stop: ItineraryStop) {
        allItineraryStops.append(stop)
        filterAndGroupStops()
    }
    
    func didUpdateItineraryStop(_ stop: ItineraryStop) {
        if let index = allItineraryStops.firstIndex(where: { $0.id == stop.id }) {
            allItineraryStops[index] = stop
            filterAndGroupStops()
        }
    }
    
    func didDeleteItineraryStop(_ stop: ItineraryStop) {
        allItineraryStops.removeAll { $0.id == stop.id }
        filterAndGroupStops()
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension CS02_ItineraryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subgroups.count + 1 // +1 for "All" option
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubgroupFilterCell", for: indexPath) as! ES03_SubgroupFilterCell
        
        if indexPath.item == 0 {
            // "All" option
            let isSelected = selectedSubgroupId == nil
            cell.configure(name: "All", colorHex: "#007AFF", isSelected: isSelected, showStar: true)
        } else {
            let subgroup = subgroups[indexPath.item - 1]
            let isSelected = selectedSubgroupId == subgroup.id
            cell.configure(name: subgroup.name, colorHex: subgroup.colorHex, isSelected: isSelected, showStar: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            selectedSubgroupId = nil
        } else {
            selectedSubgroupId = subgroups[indexPath.item - 1].id
        }
        
        collectionView.reloadData()
        filterAndGroupStops()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: 80, height: 50)
        } else {
            let subgroup = subgroups[indexPath.item - 1]
            let width = subgroup.name.size(withAttributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium)]).width + 40
            return CGSize(width: max(100, width), height: 50)
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension CS02_ItineraryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedStops.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedStops[section].stops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItineraryStopCell", for: indexPath) as! ES02_ItineraryStopCell
        
        let stop = groupedStops[indexPath.section].stops[indexPath.row]
        let subgroup = subgroups.first { $0.id == stop.subgroupId }
        
        cell.configure(with: stop, subgroup: subgroup, timeFormatter: timeFormatter)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(containerView)
        
        let iconImageView = UIImageView(image: UIImage(systemName: "calendar.circle.fill"))
        iconImageView.tintColor = .label
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconImageView)
        
        let dateLabel = UILabel()
        let dayNumber = section + 1
        let dateString = dateFormatter.string(from: groupedStops[section].date)
        dateLabel.text = "Day \(dayNumber) - \(dateString)"
        dateLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        dateLabel.textColor = .label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            containerView.heightAnchor.constraint(equalToConstant: 36),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            dateLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            dateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showEditStop", sender: indexPath)
    }
}
