//
//  CS03_AddItineraryStopVC.swift
//  TripSync
//
//  Created by Sajal Garg on 21/11/25.
//

import UIKit

protocol AddItineraryStopDelegate: AnyObject {
    func didAddItineraryStop(_ stop: ItineraryStop)
}

class CS03_AddItineraryStopVC: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var subgroupValueLabel: UILabel!
    
    // MARK: - Properties
    weak var delegate: AddItineraryStopDelegate?
    var tripId: UUID?
    var availableSubgroups: [Subgroup] = []
    var selectedSubgroup: Subgroup?
    
    private var isDatePickerVisible = false
    private var isTimePickerVisible = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDateTimeLabels()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure text fields
        titleTextField.placeholder = "Activity name"
        locationTextField.placeholder = "Address"
        titleTextField.delegate = self
        locationTextField.delegate = self
        
        // Configure date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        // Configure time picker
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.addTarget(self, action: #selector(timePickerChanged), for: .valueChanged)
        
        // Set default date to today
        datePicker.date = Date()
        timePicker.date = Date()
        
        // Setup subgroup label
        updateSubgroupLabel()
    }
    
    private func updateDateTimeLabels() {
        dateValueLabel.text = dateFormatter.string(from: datePicker.date)
        timeValueLabel.text = timeFormatter.string(from: timePicker.date)
    }
    
    @objc private func datePickerChanged() {
        dateValueLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc private func timePickerChanged() {
        timeValueLabel.text = timeFormatter.string(from: timePicker.date)
    }
    
    private func updateSubgroupLabel() {
        if let selectedSubgroup = selectedSubgroup {
            subgroupValueLabel.text = selectedSubgroup.name
        } else {
            subgroupValueLabel.text = "None"
        }
    }
    
    private func showSubgroupPicker() {
        let alert = UIAlertController(title: "Select Subgroup", message: nil, preferredStyle: .actionSheet)
        
        // Add "None" option
        alert.addAction(UIAlertAction(title: "None", style: .default) { [weak self] _ in
            self?.selectedSubgroup = nil
            self?.updateSubgroupLabel()
        })
        
        // Add subgroup options
        for subgroup in availableSubgroups {
            let title = subgroup.name + (selectedSubgroup?.id == subgroup.id ? " ✓" : "")
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.selectedSubgroup = subgroup
                self?.updateSubgroupLabel()
            })
        }
        
        // Add Create Subgroup option
        alert.addAction(UIAlertAction(title: "Create Subgroup", style: .default) { [weak self] _ in
            self?.showCreateSubgroupAlert()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showCreateSubgroupAlert() {
        let alert = UIAlertController(
            title: "Create Subgroup",
            message: "Enter a name for the new subgroup",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Subgroup name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self, weak alert] _ in
            guard let name = alert?.textFields?.first?.text, !name.isEmpty else { return }
            self?.createNewSubgroup(name: name)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createNewSubgroup(name: String) {
        guard let tripId = tripId else { return }
        
        // Generate random color
        let colors = ["systemBlue", "systemRed", "systemGreen", "systemOrange", "systemPurple", "systemPink"]
        let randomColor = colors.randomElement() ?? "systemBlue"
        
        let newSubgroup = Subgroup(
            name: name,
            description: nil,
            colorHex: randomColor,
            tripId: tripId,
            memberIds: []
        )
        
        // Add to DataModel (assuming you have a shared instance)
        // DataModel.shared.addSubgroup(newSubgroup)
        
        availableSubgroups.append(newSubgroup)
        selectedSubgroup = newSubgroup
        updateSubgroupLabel()
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Section 0: Basic Info (Title, Location)
        // Section 1: Date & Time
        // Section 2: Subgroup
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                // Date label cell tapped
                toggleDatePicker()
            } else if indexPath.row == 2 {
                // Time label cell tapped
                toggleTimePicker()
            }
        } else if indexPath.section == 2 && indexPath.row == 0 {
            // Subgroup cell tapped
            showSubgroupPicker()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Section 1: Date & Time
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                // Date picker row
                return isDatePickerVisible ? 216 : 0
            } else if indexPath.row == 3 {
                // Time picker row
                return isTimePickerVisible ? 216 : 0
            }
        }
        return UITableView.automaticDimension
    }
    
    private func toggleDatePicker() {
        isDatePickerVisible.toggle()
        
        // Hide time picker if showing date picker
        if isDatePickerVisible && isTimePickerVisible {
            isTimePickerVisible = false
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    private func toggleTimePicker() {
        isTimePickerVisible.toggle()
        
        // Hide date picker if showing time picker
        if isTimePickerVisible && isDatePickerVisible {
            isDatePickerVisible = false
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Validation
    private func validateForm() -> Bool {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "Please enter an activity name")
            return false
        }
        
        guard let location = locationTextField.text, !location.isEmpty else {
            showAlert(message: "Please enter a location")
            return false
        }
        
        return true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Missing Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        guard validateForm() else { return }
        guard let tripId = tripId else { return }
        
        let newStop = ItineraryStop(
            title: titleTextField.text ?? "",
            location: locationTextField.text ?? "",
            address: locationTextField.text ?? "",
            date: datePicker.date,
            time: timePicker.date,
            tripId: tripId,
            subgroupId: selectedSubgroup?.id,
            createdByUserId: UUID() // Replace with actual user ID
        )
        
        delegate?.didAddItineraryStop(newStop)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CS03_AddItineraryStopVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
