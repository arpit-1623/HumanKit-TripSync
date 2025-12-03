//
//  CS03_AddItineraryStopVC.swift
//  TripSync
//
//  Created by Sajal Garg on 21/11/25.
//

import UIKit

protocol AddItineraryStopDelegate: AnyObject {
    func didAddItineraryStop(_ stop: ItineraryStop)
    func didUpdateItineraryStop(_ stop: ItineraryStop)
    func didDeleteItineraryStop(_ stop: ItineraryStop)
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
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    // MARK: - Properties
    weak var delegate: AddItineraryStopDelegate?
    var tripId: UUID?
    var availableSubgroups: [Subgroup] = []
    var selectedSubgroup: Subgroup?
    var selectedCategory: (name: String, icon: String)? = ("Travel Place", "mappin.and.ellipse")
    var existingStop: ItineraryStop?
    var isEditMode: Bool { existingStop != nil }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update bar button title based on mode
        navigationItem.rightBarButtonItem?.title = isEditMode ? "Save" : "Add"
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Update title
        title = isEditMode ? "Edit Stop" : "Add Stop"
        
        // Configure text fields
        titleTextField.placeholder = "Activity name"
        locationTextField.placeholder = "Address"
        titleTextField.delegate = self
        locationTextField.delegate = self
        
        // Populate fields if editing
        if let stop = existingStop {
            titleTextField.text = stop.title
            locationTextField.text = stop.location
            datePicker.date = stop.date
            timePicker.date = stop.time
            
            if let subgroupId = stop.subgroupId {
                selectedSubgroup = availableSubgroups.first { $0.id == subgroupId }
            }
            
            if let category = stop.category {
                selectedCategory = categoryForIcon(category)
            }
        }
        
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
        
        // Setup category collection view
        setupCategoryCollectionView()
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
    
    private let categories: [(name: String, icon: String)] = [
        ("Shopping", "bag.fill"),
        ("Travel Place", "mappin.and.ellipse"),
        ("Group Collab", "person.2.fill"),
        ("Food", "fork.knife"),
        ("Transport Stop", "bus.fill"),
        ("Nature", "leaf.fill"),
        ("Stay / Hotel", "bed.double.fill"),
        ("Events / Activities", "sparkles")
    ]
    
    private func categoryForIcon(_ icon: String) -> (name: String, icon: String)? {
        return categories.first { $0.icon == icon }
    }
    
    private func setupCategoryCollectionView() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(ES04_CategoryIconCell.self, forCellWithReuseIdentifier: "CategoryIconCell")
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.isScrollEnabled = false
        
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = .zero
        }
    }
    
    private func showSubgroupPicker() {
        let alert = UIAlertController(title: "Select Subgroup", message: nil, preferredStyle: .actionSheet)
        
        // Add "None" option
        alert.addAction(UIAlertAction(title: "None", style: .default) { [weak self] _ in
            self?.selectedSubgroup = nil
            self?.updateSubgroupLabel()
        })
        
        // Add "MY" option
        let mySubgroup = Subgroup(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "MY",
            description: "My personal itinerary",
            colorHex: "#FF2D55",
            tripId: tripId ?? UUID(),
            memberIds: []
        )
        let myTitle = "MY" + (selectedSubgroup?.name == "MY" ? " ✓" : "")
        alert.addAction(UIAlertAction(title: myTitle, style: .default) { [weak self] _ in
            self?.selectedSubgroup = mySubgroup
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
        } else if indexPath.section == 3 && indexPath.row == 0 {
            // Subgroup cell tapped
            showSubgroupPicker()
        } else if indexPath.section == 4 && indexPath.row == 0 && isEditMode {
            // Delete button tapped
            deleteTapped()
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
        
        // Section 4: Delete button - hide in add mode
        if indexPath.section == 4 && !isEditMode {
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Hide delete section header in add mode
        if section == 4 && !isEditMode {
            return 0.01
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Hide delete section footer in add mode
        if section == 4 && !isEditMode {
            return 0.01
        }
        return super.tableView(tableView, heightForFooterInSection: section)
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
        
        let myItineraryFilterId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let currentUserId = DataModel.shared.getCurrentUser()?.id ?? UUID()
        let isMySubgroup = selectedSubgroup?.id == myItineraryFilterId
        
        if let existingStop = existingStop {
            // Edit mode - update existing stop
            var updatedStop = ItineraryStop(
                id: existingStop.id,
                title: titleTextField.text ?? "",
                location: locationTextField.text ?? "",
                address: locationTextField.text ?? "",
                date: datePicker.date,
                time: timePicker.date,
                tripId: tripId,
                subgroupId: isMySubgroup ? nil : selectedSubgroup?.id,
                createdByUserId: existingStop.createdByUserId,
                category: selectedCategory?.icon
            )
            
            // Mark as MY itinerary if MY subgroup was selected
            if isMySubgroup {
                updatedStop.isInMyItinerary = true
                updatedStop.addedToMyItineraryByUserId = currentUserId
            }
            
            delegate?.didUpdateItineraryStop(updatedStop)
        } else {
            // Add mode - create new stop
            var newStop = ItineraryStop(
                title: titleTextField.text ?? "",
                location: titleTextField.text ?? "",
                address: locationTextField.text ?? "",
                date: datePicker.date,
                time: timePicker.date,
                tripId: tripId,
                subgroupId: isMySubgroup ? nil : selectedSubgroup?.id,
                createdByUserId: currentUserId,
                category: selectedCategory?.icon
            )
            
            // Mark as MY itinerary if MY subgroup was selected
            if isMySubgroup {
                newStop.isInMyItinerary = true
                newStop.addedToMyItineraryByUserId = currentUserId
            }
            
            delegate?.didAddItineraryStop(newStop)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Stop",
            message: "Are you sure you want to delete this itinerary stop?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self, let stop = self.existingStop else { return }
            self.delegate?.didDeleteItineraryStop(stop)
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CS03_AddItineraryStopVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension CS03_AddItineraryStopVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryIconCell", for: indexPath) as! ES04_CategoryIconCell
        let category = categories[indexPath.item]
        let isSelected = selectedCategory?.icon == category.icon
        cell.configure(iconName: category.icon, isSelected: isSelected)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CS03_AddItineraryStopVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CS03_AddItineraryStopVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 8 * 3 // 3 gaps for 4 items per row
        let width = (collectionView.bounds.width - totalSpacing) / 4
        return CGSize(width: width, height: 58)
    }
}
