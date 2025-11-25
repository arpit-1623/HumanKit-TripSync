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
    var coverImage: UIImage!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
    }
    
    // MARK: - Configuration
    private func configureData() {
        backgroundImageView.image = coverImage
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
        
        // Convert image to data
        let imageData = coverImage.jpegData(compressionQuality: 0.8)
        
        // Create trip
        var newTrip = Trip(
            name: tripName,
            description: nil,
            location: location,
            startDate: dateRange.start,
            endDate: dateRange.end,
            createdByUserId: currentUser.id
        )
        newTrip.coverImageData = imageData
        
        // Save to DataModel
        DataModel.shared.saveTrip(newTrip)
        
        // Navigate back to home
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
