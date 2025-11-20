//
//  CA05_TripMapVC.swift
//  TripSync
//
//  Created on 20/11/2025.
//

import UIKit
import MapKit
import CoreLocation

class TripMapViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menuVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var clusterButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    // MARK: - Properties
    private var trip: DummyTrip?
    private var allMembers: [DummyUser] = []
    private var allSubgroups: [DummySubgroup] = []
    private var userLocations: [DummyUserLocation] = []
    
    private var filteredMembers: [DummyUser] = []
    private var filteredSubgroups: [DummySubgroup] = []
    
    private let locationManager = CLLocationManager()
    
    private var isMenuExpanded = false
    private let collapsedMenuHeight: CGFloat = 80
    private let expandedMenuHeight: CGFloat = 400
    
    private enum FilterMode: Int {
        case all = 0
        case subgroups = 1
    }
    
    private var currentFilterMode: FilterMode {
        return FilterMode(rawValue: filterSegmentedControl.selectedSegmentIndex) ?? .all
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMapView()
        setupLocationManager()
        setupTableView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshLocationData()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Map"
        
        // Configure menu in collapsed state
        menuHeightConstraint.constant = collapsedMenuHeight
        isMenuExpanded = false
        
        // Configure chevron button
        updateChevronButton()
        
        // Hide table view initially
        membersTableView.alpha = 0
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.showsScale = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request location permissions
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    private func setupTableView() {
        membersTableView.delegate = self
        membersTableView.dataSource = self
        membersTableView.backgroundColor = .clear
        membersTableView.separatorStyle = .none
        membersTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        // Use dummy data for now
        loadDummyData()
        
        // Update filtered data
        updateFilteredData()
    }
    
    private func loadDummyData() {
        // Create dummy trip
        trip = DummyTrip(
            id: UUID(),
            name: "Tokyo Adventure",
            location: "Tokyo, Japan"
        )
        
        // Create dummy users
        let alice = DummyUser(id: UUID(), fullName: "Alice Johnson", initials: "AJ")
        let john = DummyUser(id: UUID(), fullName: "John Doe", initials: "JD")
        let bob = DummyUser(id: UUID(), fullName: "Bob Smith", initials: "BS")
        
        allMembers = [alice, john, bob]
        
        // Create dummy user locations (Warsaw, Poland area from screenshots)
        userLocations = [
            DummyUserLocation(
                id: UUID(),
                userId: alice.id,
                latitude: 52.2319,
                longitude: 21.0122,
                isLive: true
            ),
            DummyUserLocation(
                id: UUID(),
                userId: john.id,
                latitude: 52.2297,
                longitude: 21.0122,
                isLive: false
            ),
            DummyUserLocation(
                id: UUID(),
                userId: bob.id,
                latitude: 52.2340,
                longitude: 21.0200,
                isLive: false
            )
        ]
        
        // Create dummy subgroups
        allSubgroups = [
            DummySubgroup(
                id: UUID(),
                name: "Food Explorers",
                memberIds: [alice.id, bob.id]
            ),
            DummySubgroup(
                id: UUID(),
                name: "Mountain Trek",
                memberIds: [alice.id, john.id, bob.id]
            )
        ]
        
        // Update map
        refreshLocationData()
    }
    
    private func refreshLocationData() {
        // Update map annotations
        updateMapAnnotations()
        fitMapToShowAllLocations()
    }
    
    private func updateFilteredData() {
        switch currentFilterMode {
        case .all:
            filteredMembers = allMembers
            filteredSubgroups = []
        case .subgroups:
            filteredMembers = []
            filteredSubgroups = allSubgroups
        }
        
        membersTableView.reloadData()
    }
    
    // MARK: - Map Annotation Methods
    private func updateMapAnnotations() {
        // Remove existing annotations
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        // Add annotations for each user location
        for userLocation in userLocations {
            guard let user = allMembers.first(where: { $0.id == userLocation.userId }) else {
                continue
            }
            
            let annotation = UserLocationAnnotation(user: user, location: userLocation)
            mapView.addAnnotation(annotation)
        }
    }
    
    private func fitMapToShowAllLocations() {
        guard !userLocations.isEmpty else { return }
        
        var coordinates: [CLLocationCoordinate2D] = userLocations.map { 
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        
        // Include current user location if available
        if let userLocation = locationManager.location?.coordinate {
            coordinates.append(userLocation)
        }
        
        guard coordinates.count > 0 else { return }
        
        // Calculate bounding box
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
    
    // MARK: - IBActions
    @IBAction func menuHeaderTapped(_ sender: UITapGestureRecognizer) {
        toggleMenuExpansion()
    }
    
    @IBAction func chevronButtonTapped(_ sender: UIButton) {
        toggleMenuExpansion()
    }
    
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        updateFilteredData()
    }
    
    @IBAction func clusterButtonTapped(_ sender: UIButton) {
        // Toggle clustering (future implementation)
        sender.isSelected.toggle()
    }
    
    @IBAction func centerButtonTapped(_ sender: UIButton) {
        centerMapOnUserLocation()
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Menu Animation
    private func toggleMenuExpansion() {
        isMenuExpanded.toggle()
        
        let targetHeight = isMenuExpanded ? expandedMenuHeight : collapsedMenuHeight
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.menuHeightConstraint.constant = targetHeight
            self.membersTableView.alpha = self.isMenuExpanded ? 1.0 : 0.0
            self.updateChevronButton()
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateChevronButton() {
        let imageName = isMenuExpanded ? "chevron.down" : "chevron.up"
        chevronButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func centerMapOnUserLocation() {
        guard let userLocation = locationManager.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(
            center: userLocation,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TripMapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentFilterMode {
        case .all:
            return filteredMembers.count
        case .subgroups:
            return filteredSubgroups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentFilterMode {
        case .all:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MemberLocationCell", for: indexPath) as! MemberLocationTableViewCell
            let member = filteredMembers[indexPath.row]
            let location = userLocations.first(where: { $0.userId == member.id })
            cell.configure(with: member, location: location)
            return cell
            
        case .subgroups:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubgroupCell", for: indexPath) as! SubgroupTableViewCell
            let subgroup = filteredSubgroups[indexPath.row]
            let members = allMembers.filter { subgroup.memberIds.contains($0.id) }
            cell.configure(with: subgroup, memberCount: members.count)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch currentFilterMode {
        case .all:
            // Navigate to user location on map
            let member = filteredMembers[indexPath.row]
            if let location = userLocations.first(where: { $0.userId == member.id }) {
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                )
                mapView.setRegion(region, animated: true)
                
                // Collapse menu
                if isMenuExpanded {
                    toggleMenuExpansion()
                }
            }
            
        case .subgroups:
            // Show subgroup members on map
            let subgroup = filteredSubgroups[indexPath.row]
            let subgroupLocations = userLocations.filter { location in
                subgroup.memberIds.contains(location.userId)
            }
            
            if !subgroupLocations.isEmpty {
                let coordinates = subgroupLocations.map { $0.coordinate }
                fitMapToCoordinates(coordinates)
                
                // Collapse menu
                if isMenuExpanded {
                    toggleMenuExpansion()
                }
            }
        }
    }
    
    private func fitMapToCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        guard !coordinates.isEmpty else { return }
        
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
            latitudeDelta: max((maxLat - minLat) * 1.5, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.5, 0.01)
        )
        
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension TripMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize user location annotation
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let userAnnotation = annotation as? UserLocationAnnotation else {
            return nil
        }
        
        let identifier = "UserLocationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // Create custom annotation view with initials
        let initialsView = createInitialsView(for: userAnnotation.user, isLive: userAnnotation.location.isLive)
        annotationView?.image = initialsView.asImage()
        annotationView?.centerOffset = CGPoint(x: 0, y: -initialsView.frame.height / 2)
        
        return annotationView
    }
    
    private func createInitialsView(for user: DummyUser, isLive: Bool) -> UIView {
        let size: CGFloat = 60
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        view.backgroundColor = isLive ? UIColor.systemOrange : UIColor.systemGray
        view.layer.cornerRadius = size / 2
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        
        let label = UILabel(frame: view.bounds)
        label.text = user.initials
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        view.addSubview(label)
        
        return view
    }
}

// MARK: - CLLocationManagerDelegate
extension TripMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Handle location updates if needed
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Show alert to user
            showLocationPermissionAlert()
        default:
            break
        }
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Location Access Denied",
            message: "Please enable location access in Settings to see your location on the map.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - Custom Annotation
class UserLocationAnnotation: NSObject, MKAnnotation {
    let user: DummyUser
    let location: DummyUserLocation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    var title: String? {
        return user.fullName
    }
    
    var subtitle: String? {
        return location.isLive ? "Location Live" : "Location Offline"
    }
    
    init(user: DummyUser, location: DummyUserLocation) {
        self.user = user
        self.location = location
        super.init()
    }
}

// MARK: - UIView Extension for Image Conversion
extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

// MARK: - Table View Cells

class MemberLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var initialsContainerView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationStatusLabel: UILabel!
    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    
    func configure(with user: DummyUser, location: DummyUserLocation?) {
        // Configure initials
        initialsLabel.text = user.initials
        
        // Configure name
        nameLabel.text = user.fullName
        
        // Configure location status
        if let location = location, location.isLive {
            locationStatusLabel.text = "Location Live"
            locationIconImageView.tintColor = .systemGreen
            initialsContainerView.backgroundColor = .systemOrange
        } else {
            locationStatusLabel.text = "Location Offline"
            locationIconImageView.tintColor = .systemGray
            initialsContainerView.backgroundColor = .systemGray
        }
    }
}

class SubgroupTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var membersIconImageView: UIImageView!
    
    func configure(with subgroup: DummySubgroup, memberCount: Int) {
        nameLabel.text = subgroup.name
        memberCountLabel.text = "\(memberCount) Members"
        cardView.backgroundColor = UIColor(named: "CardColor")
    }
}

// MARK: - Dummy Data Models
struct DummyTrip {
    let id: UUID
    let name: String
    let location: String
}

struct DummyUser {
    let id: UUID
    let fullName: String
    let initials: String
}

struct DummyUserLocation {
    let id: UUID
    let userId: UUID
    let latitude: Double
    let longitude: Double
    let isLive: Bool
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct DummySubgroup {
    let id: UUID
    let name: String
    let memberIds: [UUID]
}
