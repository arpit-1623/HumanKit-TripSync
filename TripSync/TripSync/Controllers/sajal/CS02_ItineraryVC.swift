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
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateTitleLabel: UILabel!
    @IBOutlet weak var emptyStateDescriptionLabel: UILabel!
    
    // MARK: - Properties
    var trip: Trip?
    var allItineraryStops: [ItineraryStop] = []
    var groupedStops: [(date: Date, stops: [ItineraryStop])] = []
    var subgroups: [Subgroup] = []
    var selectedSubgroupId: UUID? = nil // nil means "All"
    var currentUserId: UUID = DataModel.shared.getCurrentUser()?.id ?? UUID() // Current logged in user
    
    // Special UUID for MY filter
    private let myItineraryFilterId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    
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
        
        // Verify user has access to this trip
        guard let currentUser = DataModel.shared.getCurrentUser(),
              let trip = trip,
              trip.canUserAccess(currentUser.id) else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        setupUI()
        loadTripData()
        setupCollectionView()
        setupTableView()
        filterAndGroupStops()
        
        // Scroll to selected subgroup if pre-set (from navigation)
        scrollToSelectedFilter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload data in case itinerary was modified
        loadTripData()
        filterAndGroupStops()
        subgroupCollectionView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Itinerary"
        view.backgroundColor = .systemBackground
        
        // Pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        itineraryTableView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        loadTripData()
        filterAndGroupStops()
        subgroupCollectionView.reloadData()
        itineraryTableView.refreshControl?.endRefreshing()
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
    
    private func scrollToSelectedFilter() {
        guard let selectedId = selectedSubgroupId else { return }
        
        // Find the index of the selected subgroup
        if let index = subgroups.firstIndex(where: { $0.id == selectedId }) {
            let indexPath = IndexPath(item: index + 2, section: 0) // +2 for ALL and MY
            subgroupCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        } else if selectedId == myItineraryFilterId {
            let indexPath = IndexPath(item: 1, section: 0) // MY is at index 1
            subgroupCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    private func filterAndGroupStops() {
        // Filter by selected subgroup
        var filteredStops = allItineraryStops
        
        if let selectedId = selectedSubgroupId {
            if selectedId == myItineraryFilterId {
                // Filter by MY itinerary - show both created in MY and added to MY
                filteredStops = allItineraryStops.filter { 
                    ($0.isInMyItinerary && $0.addedToMyItineraryByUserId == currentUserId) || 
                    ($0.isCreatedInMySubgroup && $0.createdByUserId == currentUserId)
                }
            } else {
                // Filter by specific subgroup
                filteredStops = allItineraryStops.filter { $0.subgroupId == selectedId }
            }
        } else {
            // ALL view - exclude itineraries created in MY subgroup (private)
            filteredStops = allItineraryStops.filter { !$0.isCreatedInMySubgroup }
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
        
        // Show/hide empty state view and update text based on filter
        let isEmpty = groupedStops.isEmpty
        emptyStateView.isHidden = !isEmpty
        
        if isEmpty {
            // Update empty state text based on selected filter
            if let selectedId = selectedSubgroupId, selectedId == myItineraryFilterId {
                // MY filter selected
                emptyStateTitleLabel.text = "No My Itinerary Yet"
                emptyStateDescriptionLabel.text = "Swipe right or left from All or other subgroups to add items to My Itinerary."
            } else {
                // ALL or specific subgroup selected
                emptyStateTitleLabel.text = "No Itinerary Yet"
                emptyStateDescriptionLabel.text = "Plan your trip by adding stops to your itinerary. Tap the + button above to create your first stop."
            }
        }
        
        itineraryTableView.reloadData()
    }
    
    // MARK: - My Itinerary Actions
    private func addToMyItinerary(stop: ItineraryStop) {
        if let index = allItineraryStops.firstIndex(where: { $0.id == stop.id }) {
            allItineraryStops[index].isInMyItinerary = true
            allItineraryStops[index].addedToMyItineraryByUserId = currentUserId
            
            // Save to DataModel
            DataModel.shared.addStopToMyItinerary(stop.id, userId: currentUserId)
            DataModel.shared.saveItineraryStop(allItineraryStops[index])
            
            // Show feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Refresh view with proper filtering and grouping
            filterAndGroupStops()
            
            // Show toast message
            showToast(message: "Added to My Itinerary")
        }
    }
    
    private func removeFromMyItinerary(stop: ItineraryStop, at indexPath: IndexPath) {
        if let index = allItineraryStops.firstIndex(where: { $0.id == stop.id }) {
            // If itinerary was created in MY subgroup, delete it completely
            if stop.isCreatedInMySubgroup && stop.createdByUserId == currentUserId {
                // Delete the itinerary completely
                allItineraryStops.remove(at: index)
                DataModel.shared.deleteItineraryStop(byId: stop.id)
                
                // Show feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                
                // Refresh view
                filterAndGroupStops()
                
                // Show toast message
                showToast(message: "Deleted from My Itinerary")
            } else {
                // Just remove MY tag from itinerary created in other subgroups
                allItineraryStops[index].isInMyItinerary = false
                allItineraryStops[index].addedToMyItineraryByUserId = nil
                
                // Save to DataModel
                DataModel.shared.removeStopFromMyItinerary(stop.id, userId: currentUserId)
                DataModel.shared.saveItineraryStop(allItineraryStops[index])
                
                // Show feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                
                // Refresh view - need to filter again
                filterAndGroupStops()
                
                // Show toast message
                showToast(message: "Removed from My Itinerary")
            }
        }
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.font = .systemFont(ofSize: 14, weight: .medium)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let width: CGFloat = message.size(withAttributes: [.font: toastLabel.font!]).width + 40
        toastLabel.frame = CGRect(x: (view.frame.width - width) / 2,
                                  y: view.frame.height - 150,
                                  width: width,
                                  height: 35)
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
    
    // MARK: - Actions
    @IBAction private func addButtonTapped() {
        performSegue(withIdentifier: "showAddStop", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddStop" {
            if let navController = segue.destination as? UINavigationController,
               let addStopVC = navController.topViewController as? CS03_AddItineraryStopVC {
                addStopVC.delegate = self
                addStopVC.tripId = trip?.id
                addStopVC.trip = trip
                addStopVC.availableSubgroups = subgroups
            }
        } else if segue.identifier == "showEditStop" {
            if let navController = segue.destination as? UINavigationController,
               let addStopVC = navController.topViewController as? CS03_AddItineraryStopVC,
               let indexPath = sender as? IndexPath {
                let stop = groupedStops[indexPath.section].stops[indexPath.row]
                addStopVC.delegate = self
                addStopVC.tripId = trip?.id
                addStopVC.trip = trip
                addStopVC.availableSubgroups = subgroups
                addStopVC.existingStop = stop
            }
        }
    }
}

// MARK: - AddItineraryStopDelegate
extension CS02_ItineraryVC: AddItineraryStopDelegate {
    func didAddItineraryStop(_ stop: ItineraryStop) {
        // Save to DataModel for persistence
        DataModel.shared.saveItineraryStop(stop)
        
        // Update local array
        allItineraryStops.append(stop)
        filterAndGroupStops()
    }
    
    func didUpdateItineraryStop(_ stop: ItineraryStop) {
        // Save to DataModel for persistence
        DataModel.shared.saveItineraryStop(stop)
        
        // Update local array
        if let index = allItineraryStops.firstIndex(where: { $0.id == stop.id }) {
            allItineraryStops[index] = stop
            filterAndGroupStops()
        }
    }
    
    func didDeleteItineraryStop(_ stop: ItineraryStop) {
        // Delete from DataModel for persistence
        DataModel.shared.deleteItineraryStop(byId: stop.id)
        
        // Update local array
        allItineraryStops.removeAll { $0.id == stop.id }
        filterAndGroupStops()
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension CS02_ItineraryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subgroups.count + 2 // +1 for "All", +1 for "MY"
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubgroupFilterCell", for: indexPath) as! ES03_SubgroupFilterCell
        
        if indexPath.item == 0 {
            // "All" option
            let isSelected = selectedSubgroupId == nil
            cell.configure(name: "All", colorHex: "#007AFF", isSelected: isSelected, showStar: true)
        } else if indexPath.item == 1 {
            // "MY" option
            let isSelected = selectedSubgroupId == myItineraryFilterId
            cell.configure(name: "MY", colorHex: "#FF2D55", isSelected: isSelected, showStar: false)
        } else {
            let subgroup = subgroups[indexPath.item - 2]
            let isSelected = selectedSubgroupId == subgroup.id
            cell.configure(name: subgroup.name, colorHex: subgroup.colorHex, isSelected: isSelected, showStar: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // Select "All"
            selectedSubgroupId = nil
        } else if indexPath.item == 1 {
            // Select "MY"
            selectedSubgroupId = myItineraryFilterId
        } else {
            // Select specific subgroup
            selectedSubgroupId = subgroups[indexPath.item - 2].id
        }
        
        collectionView.reloadData()
        filterAndGroupStops()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            // "All" filter
            return CGSize(width: 80, height: 50)
        } else if indexPath.item == 1 {
            // "MY" filter
            return CGSize(width: 70, height: 50)
        } else {
            let subgroup = subgroups[indexPath.item - 2]
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
        
        // Pass flag to indicate if we're currently viewing MY itinerary filter
        let isViewingMyItinerary = (selectedSubgroupId == myItineraryFilterId)
        cell.configure(with: stop, subgroup: subgroup, timeFormatter: timeFormatter, isViewingMyItinerary: isViewingMyItinerary)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let iconImageView = UIImageView(image: UIImage(systemName: "calendar"))
        iconImageView.tintColor = .label
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(iconImageView)
        
        let dayLabel = UILabel()
        let dayNumber = section + 1
        dayLabel.text = "Day \(dayNumber)"
        dayLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        dayLabel.textColor = .label
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(dayLabel)
        
        let dateLabel = UILabel()
        let dateString = dateFormatter.string(from: groupedStops[section].date)
        dateLabel.text = dateString
        dateLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        dateLabel.textColor = .label
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            dayLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            dayLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            dateLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            dateLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: dayLabel.trailingAnchor, constant: 12)
        ])
        
        return headerView
    }
    
    // MARK: - Leading Swipe Actions (Swipe RIGHT: left-to-right)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let stop = groupedStops[indexPath.section].stops[indexPath.row]
        
        if selectedSubgroupId == myItineraryFilterId {
            // When viewing MY itinerary, show "Remove from My" action
            let removeAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] (_, _, completionHandler) in
                self?.removeFromMyItinerary(stop: stop, at: indexPath)
                completionHandler(true)
            }
            removeAction.backgroundColor = .systemRed
            removeAction.image = UIImage(systemName: "heart.slash.fill")
            
            let configuration = UISwipeActionsConfiguration(actions: [removeAction])
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        } else {
            // When viewing ALL or subgroups, show appropriate action
            if stop.isInMyItinerary {
                // Already in MY - show remove action
                let removeAction = UIContextualAction(style: .destructive, title: "Remove from My") { [weak self] (_, _, completionHandler) in
                    self?.removeFromMyItinerary(stop: stop, at: indexPath)
                    completionHandler(true)
                }
                removeAction.backgroundColor = .systemRed
                removeAction.image = UIImage(systemName: "heart.slash.fill")
                
                let configuration = UISwipeActionsConfiguration(actions: [removeAction])
                configuration.performsFirstActionWithFullSwipe = true
                return configuration
            } else {
                // Not in MY - show add action
                let addAction = UIContextualAction(style: .normal, title: "Add to My") { [weak self] (_, _, completionHandler) in
                    self?.addToMyItinerary(stop: stop)
                    completionHandler(true)
                }
                addAction.backgroundColor = .systemPink
                addAction.image = UIImage(systemName: "heart.fill")
                
                let configuration = UISwipeActionsConfiguration(actions: [addAction])
                configuration.performsFirstActionWithFullSwipe = true
                return configuration
            }
        }
    }
    
    // MARK: - Trailing Swipe Actions (Swipe LEFT: right-to-left)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let stop = groupedStops[indexPath.section].stops[indexPath.row]
        
        if selectedSubgroupId == myItineraryFilterId {
            // When viewing MY itinerary, show "Remove from My" action
            let removeAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] (_, _, completionHandler) in
                self?.removeFromMyItinerary(stop: stop, at: indexPath)
                completionHandler(true)
            }
            removeAction.backgroundColor = .systemRed
            removeAction.image = UIImage(systemName: "heart.slash.fill")
            
            return UISwipeActionsConfiguration(actions: [removeAction])
        } else {
            // When viewing ALL or subgroups, show appropriate action
            if stop.isInMyItinerary {
                // Already in MY - show remove action
                let removeAction = UIContextualAction(style: .destructive, title: "Remove from My") { [weak self] (_, _, completionHandler) in
                    self?.removeFromMyItinerary(stop: stop, at: indexPath)
                    completionHandler(true)
                }
                removeAction.backgroundColor = .systemRed
                removeAction.image = UIImage(systemName: "heart.slash.fill")
                
                return UISwipeActionsConfiguration(actions: [removeAction])
            } else {
                // Not in MY - show add action
                let addAction = UIContextualAction(style: .normal, title: "Add to My") { [weak self] (_, _, completionHandler) in
                    self?.addToMyItinerary(stop: stop)
                    completionHandler(true)
                }
                addAction.backgroundColor = .systemPink
                addAction.image = UIImage(systemName: "heart.fill")
                
                return UISwipeActionsConfiguration(actions: [addAction])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showEditStop", sender: indexPath)
    }
}
