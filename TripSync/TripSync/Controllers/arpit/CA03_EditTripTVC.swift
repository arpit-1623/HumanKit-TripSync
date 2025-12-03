//
//  CA03_EditTripVC.swift
//  TripSync
//
//  Created on 19/11/2025.
//

import UIKit

protocol EditTripDelegate: AnyObject {
    func didUpdateTrip()
}

class EditTripTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var tripLocationField: UITextField!
    
    @IBOutlet weak var startDateValueLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBOutlet weak var endDateValueLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var numberOfDaysLabel: UILabel!
    
    @IBOutlet weak var inviteCodeValueLabel: UILabel!
    @IBOutlet weak var createdDateValueLabel: UILabel!
    
    // MARK: - Properties
    private var isStartDatePickerVisible = false
    private var isEndDatePickerVisible = false
    
    private let locationCellIndexPath = IndexPath(row: 1, section: 0)
    
    private let startDateLabelCellIndexPath = IndexPath(row: 0, section: 1)
    private let startDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    private let endDateLabelCellIndexPath = IndexPath(row: 2, section: 1)
    private let endDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    private let numberOfDaysCellIndexPath = IndexPath(row: 4, section: 1)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    var trip: Trip?
    weak var delegate: EditTripDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateDateLabels()
    }
    
    // MARK: - Setup
    private func setupUI() {
        guard let trip = trip else {
            dismiss(animated: true)
            return
        }
        
        // Populate fields from trip
        tripNameField.text = trip.name
        tripLocationField.text = trip.location
        tripLocationField.isUserInteractionEnabled = false // Force use of location picker
        startDatePicker.date = trip.startDate
        endDatePicker.date = trip.endDate
        inviteCodeValueLabel.text = trip.inviteCode
        createdDateValueLabel.text = dateFormatter.string(from: trip.createdAt)
    }
    
    private func updateDateLabels() {
        startDateValueLabel.text = dateFormatter.string(from: startDatePicker.date)
        endDateValueLabel.text = dateFormatter.string(from: endDatePicker.date)
        updateNumberOfDays()
    }
    
    private func updateNumberOfDays() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDatePicker.date, to: endDatePicker.date)
        let days = components.day ?? 0
        let suffix = days == 1 ? "day" : "days"
        numberOfDaysLabel.text = "\(days) \(suffix)"
    }
    
    // MARK: - Actions
    
    @IBAction func startDatePickerChanged(_ sender: Any) {
        updateDateLabels()
    }
    
    @IBAction func endDatePickerChanged(_ sender: Any) {
        updateDateLabels()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard var trip = trip,
              let name = tripNameField.text, !name.isEmpty,
              let location = tripLocationField.text, !location.isEmpty else {
            let alert = UIAlertController(
                title: "Invalid Input",
                message: "Please fill in all required fields.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Update trip properties
        trip.name = name
        trip.location = location
        trip.startDate = startDatePicker.date
        trip.endDate = endDatePicker.date
        
        // Save to DataModel
        DataModel.shared.saveTrip(trip)
        
        // Notify delegate
        delegate?.didUpdateTrip()
        
        dismiss(animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Trip",
            message: "Are you sure you want to delete this trip? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self, let trip = self.trip else { return }
            
            DataModel.shared.deleteTrip(byId: trip.id)
            
            // Dismiss edit screen and pop to root
            self.dismiss(animated: true) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle location cell tap
        if indexPath == locationCellIndexPath {
            performSegue(withIdentifier: "editTripToLocationPicker", sender: nil)
        }
        // Handle date cell taps
        else if indexPath == startDateLabelCellIndexPath {
            toggleDatePicker(isStart: true)
        } else if indexPath == endDateLabelCellIndexPath {
            toggleDatePicker(isStart: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Date picker rows
        if indexPath == startDatePickerCellIndexPath {
            return isStartDatePickerVisible ? 216 : 0
        } else if indexPath == endDatePickerCellIndexPath {
            return isEndDatePickerVisible ? 216 : 0
        }
        
        return UITableView.automaticDimension
    }
    
    // MARK: - Helper Methods
    private func toggleDatePicker(isStart: Bool) {
        tableView.beginUpdates()
        
        if isStart {
            // Toggle start date picker
            isStartDatePickerVisible.toggle()
            
            // Close end date picker if open
            if isEndDatePickerVisible {
                isEndDatePickerVisible = false
            }
        } else {
            // Toggle end date picker
            isEndDatePickerVisible.toggle()
            
            // Close start date picker if open
            if isStartDatePickerVisible {
                isStartDatePickerVisible = false
            }
        }
        
        tableView.endUpdates()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTripToLocationPicker" {
            if let navController = segue.destination as? UINavigationController,
               let locationPickerVC = navController.topViewController as? CD03_LocationPickerVC {
                locationPickerVC.delegate = self
                locationPickerVC.initialLocation = tripLocationField.text
            }
        }
    }
}

// MARK: - LocationPickerDelegate
extension EditTripTableViewController: LocationPickerDelegate {
    func locationPicker(_ picker: CD03_LocationPickerVC, didSelectLocationDisplayName name: String) {
        tripLocationField.text = name
        trip?.location = name
    }
}
