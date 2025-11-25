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
    private var selectedImageData: Data?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        tripNameField.delegate = self
        tripNameField.becomeFirstResponder()
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let hasValidData = selectedStartDate != nil && 
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
            if let summaryVC = segue.destination as? CD05_SummaryVC,
               let tripName = tripNameField.text, !tripName.isEmpty,
               let startDate = selectedStartDate,
               let endDate = selectedEndDate,
               let location = selectedLocation {
                
                summaryVC.tripName = tripName
                summaryVC.dateRange = (start: startDate, end: endDate)
                summaryVC.location = location
                summaryVC.coverImage = backgroundImageView.image ?? UIImage(named: "createTripBg")
            }
        }
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
