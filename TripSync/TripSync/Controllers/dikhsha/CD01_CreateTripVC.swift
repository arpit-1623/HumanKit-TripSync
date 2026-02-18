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
    
    @IBOutlet weak var createRightBarButton: UIBarButtonItem!
    
    // MARK: - Properties
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    private var selectedLocation: String?
    private var selectedImageData: Data? // Deprecated: for backward compatibility
    private var selectedImageURL: String?
    private var selectedPhotographerName: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    /// Returns true if the user has entered any data into the form
    private var hasUnsavedChanges: Bool {
        let hasName = !(tripNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        return hasName || selectedStartDate != nil || selectedEndDate != nil || selectedLocation != nil || selectedImageURL != nil
    }
    
    // MARK: - Setup
    private func setupUI() {
        tripNameField.delegate = self
        tripNameField.becomeFirstResponder()
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let hasValidName = !(tripNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasValidData = hasValidName &&
                          selectedStartDate != nil && 
                          selectedEndDate != nil && 
                          selectedLocation != nil
        createRightBarButton.isEnabled = hasValidData
    }
    
    // MARK: - Actions
    @IBAction func didTapDateCard(_ sender: UIButton) {
        performSegue(withIdentifier: "createTripToDatePicker", sender: nil)
    }
    
    @IBAction func didTapLocation(_ sender: UIButton) {
        performSegue(withIdentifier: "createTripToLocationPicker", sender: nil)
    }
    
    @IBAction func didTapImage(_ sender: UIButton) {
        performSegue(withIdentifier: "createTripToImagePicker", sender: nil)
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        if hasUnsavedChanges {
            let alert = UIAlertController(
                title: "Discard Trip?",
                message: "You have unsaved changes. Are you sure you want to discard this trip?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel))
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
                self?.performSegue(withIdentifier: "unwindToHomeWithCancel", sender: nil)
            })
            present(alert, animated: true)
        } else {
            performSegue(withIdentifier: "unwindToHomeWithCancel", sender: nil)
        }
    }
    
    @IBAction func didTapCreate(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "createTripToSummary", sender: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createTripToDatePicker" {
            if let navController = segue.destination as? UINavigationController,
               let datePickerVC = navController.topViewController as? CD02_DatePickerVC {
                datePickerVC.delegate = self
            }
        } else if segue.identifier == "createTripToLocationPicker" {
            if let navController = segue.destination as? UINavigationController,
               let locationPickerVC = navController.topViewController as? CD03_LocationPickerVC {
                locationPickerVC.delegate = self
            }
        } else if segue.identifier == "createTripToImagePicker" {
            if let navController = segue.destination as? UINavigationController,
               let imagePickerVC = navController.topViewController as? CD04_ImagePickerVC {
                imagePickerVC.delegate = self
            }
        } else if segue.identifier == "createTripToSummary" {
            guard let summaryVC = segue.destination as? CD05_SummaryVC else { return }
            
            // Data is already validated in shouldPerformSegue
            // Safe to force unwrap here since validation passed
            let tripName = tripNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let startDate = selectedStartDate!
            let endDate = selectedEndDate!
            let location = selectedLocation!
            
            // Pass data to summary screen
            summaryVC.tripName = tripName
            summaryVC.dateRange = (start: startDate, end: endDate)
            summaryVC.location = location
            summaryVC.coverImageData = selectedImageData
            summaryVC.coverImageURL = selectedImageURL
            summaryVC.coverImagePhotographerName = selectedPhotographerName
        }
    }
    
    // MARK: - Helper Methods
    private func showValidationAlert(message: String) {
        let alert = UIAlertController(title: "Missing Information", message: message, preferredStyle: .alert)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Update button state when text changes
        DispatchQueue.main.async {
            self.updateCreateButtonState()
        }
        return true
    }
}

// MARK: - ImagePickerDelegate
extension CreateTripViewController: ImagePickerDelegate {
    func didSelectImage(_ image: UIImage, photoData: UnsplashPhoto) {
        backgroundImageView.image = image
        selectedImageData = image.jpegData(compressionQuality: 0.8) // Kept for backward compatibility
        selectedImageURL = photoData.urls.regular
        selectedPhotographerName = photoData.user.name
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
        
        updateCreateButtonState()
    }
}

// MARK: - LocationPickerDelegate
extension CreateTripViewController: LocationPickerDelegate {
    func locationPicker(_ picker: CD03_LocationPickerVC, didSelectLocationDisplayName name: String) {
        selectedLocation = name
        locationLabel.text = name
        locationLabel.textColor = .label
        
        updateCreateButtonState()
    }
}
