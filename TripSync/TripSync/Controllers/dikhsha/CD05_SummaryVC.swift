import UIKit

class CD05_SummaryVC: UIViewController {
    
    // MARK: - Outlets (from storyboard)
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var dateSubtitleLabel: UILabel!
    @IBOutlet weak var locationSubtitleLabel: UILabel!
    
    // MARK: - Properties
    var tripName: String!
    var dateRange: (start: Date, end: Date)!
    var location: String!
    var coverImageData: Data? // Deprecated: for backward compatibility
    var coverImageURL: String?
    var coverImagePhotographerName: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
    }
    
    // MARK: - Configuration
    private func configureData() {
        // Set background image from URL or fallback to data or placeholder
        if let imageURL = coverImageURL {
            UnsplashService.shared.loadImage(from: imageURL, placeholder: UIImage(named: "createTripBg"), into: backgroundImageView)
        } else if let imageData = coverImageData, let image = UIImage(data: imageData) {
            backgroundImageView.image = image
        } else {
            backgroundImageView.image = UIImage(named: "createTripBg")
        }
        
        tripNameLabel.text = tripName
        
        // Format dates
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let startString = formatter.string(from: dateRange.start)
        let endString = formatter.string(from: dateRange.end)
        
        dateSubtitleLabel.text = "\(startString) – \(endString)"
        locationSubtitleLabel.text = location
    }
    
    // MARK: - Actions
    @IBAction func didTapPlan(_ sender: UIButton) {
        // Get current user
        guard let currentUser = DataModel.shared.getCurrentUser() else {
            showErrorAlert(message: "Unable to create trip. Please make sure you're logged in.")
            return
        }
        
        // Create trip with image URL and metadata
        var newTrip = Trip(
            name: tripName,
            location: location,
            startDate: dateRange.start,
            endDate: dateRange.end,
            createdByUserId: currentUser.id
        )
        newTrip.coverImageData = coverImageData // Kept for backward compatibility
        newTrip.coverImageURL = coverImageURL
        newTrip.coverImagePhotographerName = coverImagePhotographerName
        
        // Save to DataModel
        do {
            try DataModel.shared.saveTripWithValidation(newTrip)
            // Navigate back to home
            navigationController?.popToRootViewController(animated: true)
        } catch {
            showErrorAlert(message: "Failed to save trip: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
