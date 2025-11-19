//
//  CA03_EditTripVC.swift
//  TripSync
//
//  Created on 19/11/2025.
//

import UIKit

class CA03_EditTripVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var tripDescView: UITextView!
    @IBOutlet weak var tripLocationField: UITextField!
    
    @IBOutlet weak var startDateValueLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBOutlet weak var endDateValueLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var inviteCodeValueLabel: UILabel!
    @IBOutlet weak var createdDateValueLabel: UILabel!
    
    // MARK: - Properties
    private var isStartDatePickerVisible = false
    private var isEndDatePickerVisible = false
    
    private let startDateLabelCellIndexPath = IndexPath(row: 0, section: 1)
    private let startDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    private let endDateLabelCellIndexPath = IndexPath(row: 2, section: 1)
    private let endDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateDateLabels()
        
        // Add actions
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Set initial date picker dates
        let calendar = Calendar.current
        if let startDate = calendar.date(from: DateComponents(year: 2025, month: 10, day: 29)),
           let endDate = calendar.date(from: DateComponents(year: 2025, month: 11, day: 5)) {
            startDatePicker.date = startDate
            endDatePicker.date = endDate
        }
    }
    
    private func updateDateLabels() {
        startDateValueLabel.text = dateFormatter.string(from: startDatePicker.date)
        endDateValueLabel.text = dateFormatter.string(from: endDatePicker.date)
    }
    
    // MARK: - Actions
    @objc private func startDateChanged() {
        updateDateLabels()
    }
    
    @objc private func endDateChanged() {
        updateDateLabels()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // TODO: Save trip changes
        dismiss(animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Trip",
            message: "Are you sure you want to delete this trip? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            // TODO: Delete trip
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle date cell taps
        if indexPath == startDateLabelCellIndexPath {
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
}
