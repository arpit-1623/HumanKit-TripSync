//
//  CD01_CreateTripVC.swift
//  TripSync
//
//  Created on 24/11/2025.
//

import UIKit
import PhotosUI

class CreateTripViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var dateCardButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var dateSmallLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // MARK: - Properties
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    private var selectedLocation: String?
    private var selectedImageData: Data?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure trip name field
        tripNameField.delegate = self
        tripNameField.becomeFirstResponder()
        
        // Configure date label
        dateSmallLabel.text = "Set Dates"
        dateSmallLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        dateSmallLabel.textColor = UIColor(white: 0.33, alpha: 1.0)
    }
    
    private func setupNavigationBar() {
        title = "Create Trip"
        
        // Add cancel button
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        // Add create button
        let createButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createButtonTapped))
        navigationItem.rightBarButtonItem = createButton
    }
    
    // MARK: - Actions
    @IBAction func didTapDateCard(_ sender: UIButton) {
        presentDatePicker()
    }
    
    private func presentDatePicker() {
        let storyboard = UIStoryboard(name: "SD02_DatePicker", bundle: nil)
        guard let datePickerVC = storyboard.instantiateViewController(withIdentifier: "CD02_DatePickerVC") as? CD02_DatePickerVC else {
            return
        }
        
        datePickerVC.delegate = self
        datePickerVC.modalPresentationStyle = .pageSheet
        
        if let sheet = datePickerVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(datePickerVC, animated: true)
    }
    
    @IBAction func didTapLocation(_ sender: UIButton) {
        presentLocationPicker()
    }
    
    private func presentLocationPicker() {
        let storyboard = UIStoryboard(name: "SD03_LocationPicker", bundle: nil)
        guard let locationPickerVC = storyboard.instantiateViewController(withIdentifier: "CD03_LocationPickerVC") as? CD03_LocationPickerVC else {
            return
        }
        
        locationPickerVC.delegate = self
        locationPickerVC.modalPresentationStyle = .pageSheet
        
        if let sheet = locationPickerVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(locationPickerVC, animated: true)
    }
    
    @IBAction func didTapImage(_ sender: UIButton) {
        presentImagePicker()
    }
    
    @objc private func cancelButtonTapped() {
        // Dismiss or pop based on presentation
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func createButtonTapped() {
        // Validate inputs
        guard let tripName = tripNameField.text, !tripName.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter a trip name.")
            return
        }
        
        guard let startDate = selectedStartDate, let endDate = selectedEndDate else {
            showAlert(title: "Missing Information", message: "Please select trip dates.")
            return
        }
        
        guard let location = selectedLocation, !location.isEmpty else {
            showAlert(title: "Missing Information", message: "Please select a location.")
            return
        }
        
        // Navigate to summary screen
        let summaryVC = CD05_SummaryVC()
        summaryVC.tripName = tripName
        summaryVC.dateRange = (start: startDate, end: endDate)
        summaryVC.location = location
        summaryVC.coverImage = backgroundImageView.image ?? UIImage(named: "createTripBg")
        navigationController?.pushViewController(summaryVC, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func presentImagePicker() {
        let storyboard = UIStoryboard(name: "SD04_ImagePicker", bundle: nil)
        guard let imagePickerVC = storyboard.instantiateInitialViewController() as? CD04_ImagePickerVC else {
            return
        }
        
        imagePickerVC.delegate = self
        imagePickerVC.modalPresentationStyle = .pageSheet
        
        if let sheet = imagePickerVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(imagePickerVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreateTripViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ImagePickerDelegate
extension CreateTripViewController: ImagePickerDelegate {
    func didSelectImage(_ image: UIImage, photoData: UnsplashPhoto) {
        backgroundImageView.image = image
        selectedImageData = image.jpegData(compressionQuality: 0.8)
    }
}

// MARK: - DateRangePickerDelegate
extension CreateTripViewController: DateRangePickerDelegate {
    func didSelectDateRange(start: Date, end: Date) {
        selectedStartDate = start
        selectedEndDate = end
        
        // Update the date label
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: start)
        let endYear = calendar.component(.year, from: end)
        
        var dateRangeText: String
        if startYear == endYear {
            // Same year: "5 Jan - 11 Jan 2025"
            dateRangeText = "\(formatter.string(from: start)) - \(formatter.string(from: end)) \(startYear)"
        } else {
            // Different years: "28 Dec 2024 - 3 Jan 2025"
            formatter.dateFormat = "d MMM yyyy"
            dateRangeText = "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
        
        dateSmallLabel.text = dateRangeText
        dateSmallLabel.textColor = .label
    }
}

// MARK: - LocationPickerDelegate
extension CreateTripViewController: LocationPickerDelegate {
    func locationPicker(_ picker: CD03_LocationPickerVC, didSelectLocationDisplayName name: String) {
        selectedLocation = name
        locationLabel.text = name
        locationLabel.textColor = .label
    }
}
