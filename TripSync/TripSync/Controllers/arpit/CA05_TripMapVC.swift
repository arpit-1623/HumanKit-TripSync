//
//  CA05_TripMapVC.swift
//  TripSync
//
//  Created by Arpit Garg on 21/11/25.
//

import UIKit
import MapKit
import CoreLocation

class TripMapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var focusAllButton: UIButton!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var subgroupTableView: UITableView!
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var trip: Trip?
    var members: [User] = []
    var filteredMembers: [User] = []
    var subgroups: [Subgroup] = []
    var locations: [UserLocation] = []
    var selectedSubgroup: Subgroup?
    
    private let locationManager = CLLocationManager()
    private var userAnnotations: [UUID: MKPointAnnotation] = [:]
    private let collapsedHeight: CGFloat = 80
    private let expandedHeight: CGFloat = 360
    private var isMenuExpanded = false
    
    enum MenuMode {
        case all
        case subgroups
        case subgroupMembers
    }
    
    private var currentMenuMode: MenuMode = .all
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
        setupLocationManager()
        setupTableViews()
        loadTripData()
        setupFloatingButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLocationUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLocationUpdates()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Map"
        
        // Configure menu container
        menuContainerView.layer.cornerRadius = 16
        menuContainerView.layer.shadowColor = UIColor.black.cgColor
        menuContainerView.layer.shadowOpacity = 0.1
        menuContainerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        menuContainerView.layer.shadowRadius = 8
        menuContainerView.clipsToBounds = false
        
        // Set initial collapsed state
        menuHeightConstraint.constant = collapsedHeight
        
        // Add tap gesture to menu for expanding
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))
        menuContainerView.addGestureRecognizer(tapGesture)
        
        // Configure segmented control
        segmentedControl.setTitle("All", forSegmentAt: 0)
        segmentedControl.setTitle("Subgroups", forSegmentAt: 1)
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupTableViews() {
        // Configure member table view
        memberTableView.delegate = self
        memberTableView.dataSource = self
        memberTableView.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        memberTableView.backgroundColor = .clear
        
        // Configure subgroup table view
        subgroupTableView.delegate = self
        subgroupTableView.dataSource = self
        subgroupTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        subgroupTableView.backgroundColor = .clear
        subgroupTableView.isHidden = true
    }
    
    private func setupFloatingButtons() {
        // Style current location button
        currentLocationButton.layer.cornerRadius = 24
        currentLocationButton.layer.shadowColor = UIColor.black.cgColor
        currentLocationButton.layer.shadowOpacity = 0.2
        currentLocationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        currentLocationButton.layer.shadowRadius = 4
        
        // Style focus all button
        focusAllButton.layer.cornerRadius = 24
        focusAllButton.layer.shadowColor = UIColor.black.cgColor
        focusAllButton.layer.shadowOpacity = 0.2
        focusAllButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        focusAllButton.layer.shadowRadius = 4
    }
    
    private func loadTripData() {
        guard let trip = trip else { return }
        
        // Load members
        members = trip.memberIds.compactMap { DataModel.shared.getUser(byId: $0) }
        filteredMembers = members
        
        // Load subgroups
        subgroups = DataModel.shared.getSubgroups(forTripId: trip.id)
        
        // Load locations
        locations = DataModel.shared.getLocations(forTripId: trip.id)
        
        // If no locations exist, create dummy locations for testing
        if locations.isEmpty {
            loadDummyLocations()
        }
        
        // Update map annotations
        updateMapAnnotations()
        
        // Focus map to show all members
        focusMapOnAllMembers()
        
        // Reload table views
        memberTableView.reloadData()
        subgroupTableView.reloadData()
    }
    
    private func loadDummyLocations() {
        // Create dummy locations around Warsaw, Poland for testing
        let baseCoordinates: [(lat: Double, lon: Double)] = [
            (52.2319, 21.0122),  // Center
            (52.2297, 21.0122),  // South
            (52.2250, 21.0100),  // Southwest
            (52.2280, 21.0140),  // East
        ]
        
        for (index, member) in members.enumerated() {
            let coordIndex = index % baseCoordinates.count
            let coord = baseCoordinates[coordIndex]
            let coordinate = CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon)
            let isLive = index % 3 != 2 // Every third member is offline
            
            let location = UserLocation(
                userId: member.id,
                tripId: trip?.id ?? UUID(),
                coordinate: coordinate,
                isLive: isLive
            )
            locations.append(location)
        }
    }
    
    private func updateMapAnnotations() {
        // Remove old annotations
        mapView.removeAnnotations(userAnnotations.values.map { $0 })
        userAnnotations.removeAll()
        
        // Add new annotations for each member with location
        for member in filteredMembers {
            guard let location = locations.first(where: { $0.userId == member.id }) else { continue }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = member.fullName
            annotation.subtitle = location.isLive ? "Location Live" : "Last seen \(formatTimestamp(location.timestamp))"
            
            mapView.addAnnotation(annotation)
            userAnnotations[member.id] = annotation
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        guard let userLocation = mapView.userLocation.location else { return }
        
        let region = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func focusAllButtonTapped(_ sender: Any) {
        focusMapOnAllMembers()
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Show all members
            currentMenuMode = .all
            filteredMembers = members
            memberTableView.isHidden = false
            subgroupTableView.isHidden = true
        } else {
            // Show subgroups
            currentMenuMode = .subgroups
            memberTableView.isHidden = true
            subgroupTableView.isHidden = false
        }
        
        updateMapAnnotations()
        memberTableView.reloadData()
        subgroupTableView.reloadData()
    }
    
    @objc private func toggleMenu() {
        isMenuExpanded.toggle()
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.menuHeightConstraint.constant = self.isMenuExpanded ? self.expandedHeight : self.collapsedHeight
            self.view.layoutIfNeeded()
        }
    }
    
    private func focusMapOnAllMembers() {
        let coordinates = locations.filter { location in
            filteredMembers.contains(where: { $0.id == location.userId })
        }.map { $0.coordinate }
        
        guard !coordinates.isEmpty else { return }
        
        if coordinates.count == 1 {
            let region = MKCoordinateRegion(
                center: coordinates[0],
                latitudinalMeters: 2000,
                longitudinalMeters: 2000
            )
            mapView.setRegion(region, animated: true)
        } else {
            var minLat = coordinates[0].latitude
            var maxLat = coordinates[0].latitude
            var minLon = coordinates[0].longitude
            var maxLon = coordinates[0].longitude
            
            for coordinate in coordinates {
                minLat = min(minLat, coordinate.latitude)
                maxLat = max(maxLat, coordinate.latitude)
                minLon = min(minLon, coordinate.longitude)
                maxLon = max(maxLon, coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )
            
            let span = MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.5,
                longitudeDelta: (maxLon - minLon) * 1.5
            )
            
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        // In a real app, you would also start a timer or observer to fetch other users' locations
    }
    
    private func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - MKMapViewDelegate
extension TripMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize user location annotation
        guard !(annotation is MKUserLocation) else { return nil }
        
        let identifier = "MemberAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // Find the member for this annotation
        if let member = members.first(where: { userAnnotations[$0.id] == annotation as? MKPointAnnotation }),
           let location = locations.first(where: { $0.userId == member.id }) {
            
            // Create custom annotation image with initials
            let size = CGSize(width: 40, height: 40)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { context in
                // Draw circle background
                let color = location.isLive ? UIColor.systemOrange : UIColor.systemGray
                color.setFill()
                context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
                
                // Draw initials
                let initials = member.initials
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: UIColor.white
                ]
                let textSize = initials.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: (size.width - textSize.width) / 2,
                    y: (size.height - textSize.height) / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                initials.draw(in: textRect, withAttributes: attributes)
                
                // Draw live indicator if applicable
                if location.isLive {
                    let indicatorSize: CGFloat = 12
                    let indicatorRect = CGRect(
                        x: size.width - indicatorSize - 2,
                        y: 2,
                        width: indicatorSize,
                        height: indicatorSize
                    )
                    UIColor.systemGreen.setFill()
                    context.cgContext.fillEllipse(in: indicatorRect)
                    UIColor.white.setStroke()
                    context.cgContext.setLineWidth(2)
                    context.cgContext.strokeEllipse(in: indicatorRect)
                }
            }
            
            annotationView?.image = image
        }
        
        return annotationView
    }
}

// MARK: - CLLocationManagerDelegate
extension TripMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update current user's location in DataModel
        guard let currentLocation = locations.last,
              let trip = trip,
              let currentUser = DataModel.shared.getCurrentUser() else { return }
        
        let userLocation = UserLocation(
            userId: currentUser.id,
            tripId: trip.id,
            coordinate: currentLocation.coordinate,
            isLive: true
        )
        
        DataModel.shared.saveLocation(userLocation)
        
        // Update local locations array
        if let index = self.locations.firstIndex(where: { $0.userId == currentUser.id && $0.tripId == trip.id }) {
            self.locations[index] = userLocation
        } else {
            self.locations.append(userLocation)
        }
        
        // Update map annotation for current user
        updateMapAnnotations()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Show alert to user
            let alert = UIAlertController(
                title: "Location Access Needed",
                message: "Please enable location access in Settings to share your location with trip members.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource
extension TripMapViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == memberTableView {
            return currentMenuMode == .all ? filteredMembers.count : (selectedSubgroup != nil ? filteredMembers.count : 0)
        } else {
            return subgroups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == memberTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MemberMapCell", for: indexPath)
            let member = filteredMembers[indexPath.row]
            let location = locations.first(where: { $0.userId == member.id })
            
            // Configure cell (this will be styled in storyboard)
            cell.textLabel?.text = member.fullName
            cell.detailTextLabel?.text = location?.isLive == true ? "Live" : "Offline"
            cell.backgroundColor = .clear
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubgroupCell", for: indexPath)
            let subgroup = subgroups[indexPath.row]
            
            cell.textLabel?.text = subgroup.name
            cell.detailTextLabel?.text = "\(subgroup.memberIds.count) Members"
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = .clear
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension TripMapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == subgroupTableView {
            // Show members of selected subgroup
            selectedSubgroup = subgroups[indexPath.row]
            currentMenuMode = .subgroupMembers
            
            filteredMembers = members.filter { member in
                selectedSubgroup?.memberIds.contains(member.id) == true
            }
            
            memberTableView.isHidden = false
            subgroupTableView.isHidden = true
            memberTableView.reloadData()
            
            updateMapAnnotations()
        } else if tableView == memberTableView {
            // Optionally: Focus on selected member
            let member = filteredMembers[indexPath.row]
            if let annotation = userAnnotations[member.id] {
                mapView.selectAnnotation(annotation, animated: true)
                
                let region = MKCoordinateRegion(
                    center: annotation.coordinate,
                    latitudinalMeters: 500,
                    longitudinalMeters: 500
                )
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
