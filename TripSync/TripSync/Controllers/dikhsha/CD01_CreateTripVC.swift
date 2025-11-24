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
        // TODO: Push SD01_DatePickerVC
        print("Date card tapped")
    }
    
    @IBAction func didTapLocation(_ sender: UIButton) {
        // TODO: Push SD01_LocationPickerVC
        print("Location button tapped")
    }
    
    @IBAction func didTapImage(_ sender: UIButton) {
        // TODO: Present PHPickerViewController
        print("Image button tapped")
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
        
        // Create trip
        createTrip(name: tripName, location: location, startDate: startDate, endDate: endDate)
    }
    
    // MARK: - Helper Methods
    private func createTrip(name: String, location: String, startDate: Date, endDate: Date) {
        // Get current user
        guard let currentUser = DataModel.shared.getCurrentUser() else {
            showAlert(title: "Error", message: "Unable to get current user.")
            return
        }
        
        // Create new trip
        var newTrip = Trip(
            name: name,
            description: nil,
            location: location,
            startDate: startDate,
            endDate: endDate,
            createdByUserId: currentUser.id
        )
        
        // Add cover image if selected
        if let imageData = selectedImageData {
            newTrip.coverImageData = imageData
        }
        
        // Save trip
        DataModel.shared.saveTrip(newTrip)
        
        // Navigate back
        navigationController?.popViewController(animated: true)
    }
    
    private func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
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

// MARK: - PHPickerViewControllerDelegate
extension CreateTripViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.selectedImageData = image.jpegData(compressionQuality: 0.8)
                    print("Image selected")
                }
            }
        }
    }
}
