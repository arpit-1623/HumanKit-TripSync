import UIKit

class CD05_SummaryVC: UIViewController {
    
    // MARK: - Properties
    var tripName: String!
    var dateRange: (start: Date, end: Date)!
    var location: String!
    var coverImage: UIImage!
    
    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let overlayView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.alpha = 0.25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tripNameBubble: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        return view
    }()
    
    private let tripNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateBubble = InfoBubbleView()
    private let locationBubble = InfoBubbleView()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let planButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Plan", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let arrowButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = UIImage(systemName: "arrow.right.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add background image
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        
        // Setup trip name bubble
        let nameBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
        nameBlur.translatesAutoresizingMaskIntoConstraints = false
        tripNameBubble.addSubview(nameBlur)
        tripNameBubble.addSubview(tripNameLabel)
        
        // Add to stack
        contentStackView.addArrangedSubview(tripNameBubble)
        contentStackView.addArrangedSubview(dateBubble)
        contentStackView.addArrangedSubview(locationBubble)
        
        view.addSubview(contentStackView)
        view.addSubview(planButton)
        view.addSubview(arrowButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Background
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Name bubble blur
            nameBlur.topAnchor.constraint(equalTo: tripNameBubble.topAnchor),
            nameBlur.leadingAnchor.constraint(equalTo: tripNameBubble.leadingAnchor),
            nameBlur.trailingAnchor.constraint(equalTo: tripNameBubble.trailingAnchor),
            nameBlur.bottomAnchor.constraint(equalTo: tripNameBubble.bottomAnchor),
            
            // Name label
            tripNameLabel.topAnchor.constraint(equalTo: tripNameBubble.topAnchor, constant: 20),
            tripNameLabel.leadingAnchor.constraint(equalTo: tripNameBubble.leadingAnchor, constant: 32),
            tripNameLabel.trailingAnchor.constraint(equalTo: tripNameBubble.trailingAnchor, constant: -32),
            tripNameLabel.bottomAnchor.constraint(equalTo: tripNameBubble.bottomAnchor, constant: -20),
            
            // Content stack
            contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // Date bubble
            dateBubble.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            dateBubble.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            
            // Location bubble
            locationBubble.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            locationBubble.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            
            // Plan button
            arrowButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            arrowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            arrowButton.widthAnchor.constraint(equalToConstant: 44),
            arrowButton.heightAnchor.constraint(equalToConstant: 44),
            
            planButton.trailingAnchor.constraint(equalTo: arrowButton.leadingAnchor, constant: -8),
            planButton.centerYAnchor.constraint(equalTo: arrowButton.centerYAnchor)
        ])
        
        // Actions
        planButton.addTarget(self, action: #selector(didTapPlan), for: .touchUpInside)
        arrowButton.addTarget(self, action: #selector(didTapPlan), for: .touchUpInside)
    }
    
    private func configureData() {
        backgroundImageView.image = coverImage
        tripNameLabel.text = tripName
        
        // Configure date bubble
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let startString = formatter.string(from: dateRange.start)
        let endString = formatter.string(from: dateRange.end)
        
        dateBubble.configure(
            icon: "calendar",
            title: "Trip Dates",
            subtitle: "\(startString) – \(endString)"
        )
        
        // Configure location bubble
        locationBubble.configure(
            icon: "mappin.and.ellipse",
            title: "Location",
            subtitle: location
        )
    }
    
    // MARK: - Actions
    @objc private func didTapPlan() {
        // Navigate to home or planning screen
        // For now, pop to root
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - InfoBubbleView
class InfoBubbleView: UIView {
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 20
        clipsToBounds = true
        
        addSubview(blurView)
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            // Blur
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            // Height
            heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }
    
    func configure(icon: String, title: String, subtitle: String) {
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
