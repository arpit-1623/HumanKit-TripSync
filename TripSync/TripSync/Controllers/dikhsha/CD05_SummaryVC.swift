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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        navigationController?.popToRootViewController(animated: true)
    }
}
