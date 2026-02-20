//
//  CS04_SubgroupFormVC.swift
//  TripSync
//
//  Created by Sajal Garg on 21/11/25.
//

import UIKit

protocol SubgroupFormDelegate: AnyObject {
    func didCreateSubgroup(_ subgroup: Subgroup)
    func didUpdateSubgroup(_ subgroup: Subgroup)
}

class CS04_SubgroupFormVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // Color buttons (11 colors)
    @IBOutlet weak var color1Button: UIButton!
    @IBOutlet weak var color2Button: UIButton!
    @IBOutlet weak var color3Button: UIButton!
    @IBOutlet weak var color4Button: UIButton!
    @IBOutlet weak var color5Button: UIButton!
    @IBOutlet weak var color6Button: UIButton!
    @IBOutlet weak var color7Button: UIButton!
    @IBOutlet weak var color8Button: UIButton!
    @IBOutlet weak var color9Button: UIButton!
    @IBOutlet weak var color10Button: UIButton!
    
    // Details section (for edit mode)
    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    // MARK: - Properties
    weak var delegate: SubgroupFormDelegate?
    var trip: Trip?
    var tripId: UUID?
    var existingSubgroup: Subgroup?
    
    private var selectedColorHex: String = "#FF6B6B"
    private var selectedMemberIds = Set<UUID>()
    private var isEditMode: Bool {
        return existingSubgroup != nil
    }
    
    private let availableColors = [
        "#FF6B6B", "#4ECDC4", "#FFD93D", "#6BCB77", "#C77DFF",
        "#FF8787", "#4D96FF", "#FFB84D", "#A8E6CF", "#FF6AC1"
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupColorButtons()
        loadExistingData()
        
        if isEditMode {
            loadDetailsSection()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set navigation bar presentation style
        if let navController = navigationController {
            navController.modalPresentationStyle = .pageSheet
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = isEditMode ? "Edit Circle" : "Create Circle"
        
        // Name text field
        nameTextField.placeholder = "Circle Name"
        nameTextField.borderStyle = .none
        
        // Description text field
        descriptionTextField.placeholder = "Description"
        descriptionTextField.borderStyle = .none
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
    }
    

    
    private func setupColorButtons() {
        let buttons = [color1Button, color2Button, color3Button, color4Button, color5Button,
                      color6Button, color7Button, color8Button, color9Button, color10Button]
        
        for (index, button) in buttons.enumerated() {
            guard let button = button, index < availableColors.count else { continue }
            
            let colorHex = availableColors[index]
            button.backgroundColor = UIColor(hex: colorHex)
            button.layer.cornerRadius = 25
            button.clipsToBounds = true
            button.tag = index
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            
            // Add checkmark to first color by default
            if index == 0 {
                addCheckmark(to: button)
            }
        }
    }
    
    private func loadExistingData() {
        guard let subgroup = existingSubgroup else { return }
        
        nameTextField.text = subgroup.name
        descriptionTextField.text = subgroup.description ?? ""
        
        selectedColorHex = subgroup.colorHex
        selectedMemberIds = Set(subgroup.memberIds)
        
        // Update color button selection
        if let colorIndex = availableColors.firstIndex(of: subgroup.colorHex) {
            let buttons = [color1Button, color2Button, color3Button, color4Button, color5Button,
                          color6Button, color7Button, color8Button, color9Button, color10Button]
            
            buttons.forEach { removeCheckmark(from: $0) }
            if let button = buttons[colorIndex] {
                addCheckmark(to: button)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @IBAction private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a subgroup name")
            return
        }
        
        guard let tripId = tripId else { return }
        
        let description = descriptionTextField.text?.isEmpty == false ? descriptionTextField.text : nil
        
        if let existingSubgroup = existingSubgroup {
            // Update existing subgroup - keep current members
            var updatedSubgroup = existingSubgroup
            updatedSubgroup.name = name
            updatedSubgroup.description = description
            updatedSubgroup.colorHex = selectedColorHex
            // memberIds unchanged in edit mode
            updatedSubgroup.updatedAt = Date()
            
            delegate?.didUpdateSubgroup(updatedSubgroup)
        } else {
            // Create new subgroup - add current user as member by default
            guard let currentUser = DataModel.shared.getCurrentUser() else {
                showAlert(title: "Error", message: "Unable to create subgroup")
                return
            }
            
            let newSubgroup = Subgroup(
                name: name,
                description: description,
                colorHex: selectedColorHex,
                tripId: tripId,
                memberIds: [currentUser.id],
                createdByUserId: currentUser.id
            )
            
            delegate?.didCreateSubgroup(newSubgroup)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        let buttons = [color1Button, color2Button, color3Button, color4Button, color5Button,
                      color6Button, color7Button, color8Button, color9Button, color10Button]
        
        // Remove checkmarks from all buttons
        buttons.forEach { removeCheckmark(from: $0) }
        
        // Add checkmark to selected button
        addCheckmark(to: sender)
        
        // Update selected color
        selectedColorHex = availableColors[sender.tag]
    }
    
    private func addCheckmark(to button: UIButton?) {
        guard let button = button else { return }
        
        // Remove existing checkmark
        button.subviews.first(where: { $0.tag == 999 })?.removeFromSuperview()
        
        let checkmarkImage = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmarkImage.tintColor = .white
        checkmarkImage.contentMode = .scaleAspectFit
        checkmarkImage.tag = 999
        checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(checkmarkImage)
        
        NSLayoutConstraint.activate([
            checkmarkImage.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            checkmarkImage.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            checkmarkImage.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImage.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func removeCheckmark(from button: UIButton?) {
        button?.subviews.first(where: { $0.tag == 999 })?.removeFromSuperview()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func loadDetailsSection() {
        guard let subgroup = existingSubgroup else { return }
        
        // Members count
        membersCountLabel?.text = "\(subgroup.memberIds.count)"
        
        // Created date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        createdDateLabel?.text = dateFormatter.string(from: subgroup.createdAt)
    }
    
    @IBAction func deleteSubgroupTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Subgroup",
            message: "Are you sure you want to delete this subgroup? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self, let subgroup = self.existingSubgroup else { return }
            
            DataModel.shared.deleteSubgroup(byId: subgroup.id)
            
            performSegue(withIdentifier: "unwindToTripDetailsWithDeleteSubgroup", sender: nil)
        })
        present(alert, animated: true)
    }
    
    // MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isEditMode ? 4 : 2 // Edit: Information, Color, Details, Delete | Create: Information, Color
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEditMode {
            switch section {
            case 0: return 2 // Name, Description
            case 1: return 1 // Color selector
            case 2: return 2 // Members count, Created date
            case 3: return 1 // Delete button
            default: return 0
            }
        } else {
            switch section {
            case 0: return 2 // Name, Description
            case 1: return 1 // Color selector
            default: return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isEditMode {
            switch section {
            case 0: return "CIRCLE INFORMATION"
            case 1: return "COLOR"
            case 2: return "DETAILS"
            case 3: return "DELETE CIRCLE"
            default: return nil
            }
        } else {
            switch section {
            case 0: return "CIRCLE INFORMATION"
            case 1: return "COLOR"
            default: return nil
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // In edit mode, section 3 is Delete - style the delete button
        if isEditMode && indexPath.section == 3 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            
            // Style the delete button
            if let deleteButton = cell.contentView.subviews.first(where: { $0 is UIButton }) as? UIButton {
                deleteButton.layer.cornerRadius = 12
                deleteButton.layer.masksToBounds = true
            }
            
            return cell
        }
        
        // All other cells (sections 0, 1, and 2 in edit mode) are static
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEditMode {
            switch indexPath.section {
            case 0:
                return 50 // Name field, Description field
            case 1:
                return 150 // Color buttons grid
            case 2:
                return 44 // Details cells
            case 3:
                return 60 // Delete button
            default:
                return 44
            }
        } else {
            switch indexPath.section {
            case 0:
                return 50 // Name field, Description field
            case 1:
                return 150 // Color buttons grid
            default:
                return 44
            }
        }
    }
}


