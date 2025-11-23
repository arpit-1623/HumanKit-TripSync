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
    @IBOutlet weak var descriptionTextView: UITextView!
    
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
    @IBOutlet weak var color11Button: UIButton!
    @IBOutlet weak var color12Button: UIButton!
    
    // Details section (for edit mode)
    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    // MARK: - Properties
    weak var delegate: SubgroupFormDelegate?
    var trip: Trip?
    var tripId: UUID?
    var tripMembers: [User] = []
    var existingSubgroup: Subgroup?
    
    private var selectedColorHex: String = "#FF6B6B" // Default pink
    private var selectedMemberIds: Set<UUID> = []
    private var isEditMode: Bool {
        return existingSubgroup != nil
    }
    
    private let availableColors = [
        "#FF6B9D", "#4ECDC4", "#45B7D1", "#F4A259",
        "#95E1D3", "#F7DC6F", "#B19CD9", "#5DADE2",
        "#58D68D", "#F5B041", "#EC7063", "#A569BD"
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
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
        title = isEditMode ? "Edit Subgroup" : "Create Subgroup"
        
        // Name text field
        nameTextField.placeholder = "Subgroup Name"
        nameTextField.borderStyle = .none
        
        // Description text view
        descriptionTextView.text = "Description (Optional)"
        descriptionTextView.textColor = .placeholderText
        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.delegate = self
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
    }
    
    private func setupNavigationBar() {
        // Close button
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .label
        navigationItem.leftBarButtonItem = closeButton
        
        // Save button
        let saveButton = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupColorButtons() {
        let buttons = [color1Button, color2Button, color3Button, color4Button, color5Button,
                      color6Button, color7Button, color8Button, color9Button, color10Button, color11Button, color12Button]
        
        for (index, button) in buttons.enumerated() {
            guard let button = button, index < availableColors.count else { continue }
            
            let colorHex = availableColors[index]
            button.backgroundColor = UIColor(hex: colorHex)
            button.layer.cornerRadius = 25
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
        
        if let description = subgroup.description, !description.isEmpty {
            descriptionTextView.text = description
            descriptionTextView.textColor = .label
        }
        
        selectedColorHex = subgroup.colorHex
        selectedMemberIds = Set(subgroup.memberIds)
        
        // Update color button selection
        if let colorIndex = availableColors.firstIndex(of: subgroup.colorHex) {
            let buttons = [color1Button, color2Button, color3Button, color4Button, color5Button,
                          color6Button, color7Button, color8Button, color9Button, color10Button, color11Button, color12Button]
            
            buttons.forEach { removeCheckmark(from: $0) }
            if let button = buttons[colorIndex] {
                addCheckmark(to: button)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a subgroup name")
            return
        }
        
        // Only validate member selection in create mode
        if !isEditMode {
            guard !selectedMemberIds.isEmpty else {
                showAlert(title: "Error", message: "Please select at least one member")
                return
            }
        }
        
        guard let tripId = tripId else { return }
        
        let description = descriptionTextView.text == "Description (Optional)" ? nil : descriptionTextView.text
        
        if let existingSubgroup = existingSubgroup {
            // Update existing subgroup
            var updatedSubgroup = existingSubgroup
            updatedSubgroup.name = name
            updatedSubgroup.description = description
            updatedSubgroup.colorHex = selectedColorHex
            updatedSubgroup.memberIds = Array(selectedMemberIds)
            updatedSubgroup.updatedAt = Date()
            
            delegate?.didUpdateSubgroup(updatedSubgroup)
        } else {
            // Create new subgroup
            let newSubgroup = Subgroup(
                name: name,
                description: description,
                colorHex: selectedColorHex,
                tripId: tripId,
                memberIds: Array(selectedMemberIds)
            )
            
            delegate?.didCreateSubgroup(newSubgroup)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        let buttons = [color1Button, color2Button, color3Button, color4Button, color5Button,
                      color6Button, color7Button, color8Button, color9Button, color10Button, color11Button, color12Button]
        
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
            
            // Remove subgroup from trip
            DataModel.shared.deleteSubgroup(subgroup)
            
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isEditMode ? 4 : 3 // Edit: Information, Color, Details, Delete | Create: Information, Color, Members
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
            case 2: return tripMembers.count // Member list
            default: return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isEditMode {
            switch section {
            case 0: return "SUBGROUP INFORMATION"
            case 1: return "COLOR"
            case 2: return "DETAILS"
            case 3: return "DELETE SUBGROUP"
            default: return nil
            }
        } else {
            switch section {
            case 0: return "SUBGROUP INFORMATION"
            case 1: return "COLOR"
            case 2: return "SELECT MEMBERS"
            default: return nil
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if isEditMode {
            if section == 3 {
                return "Deleting this subgroup will remove it from the trip permanently."
            }
        } else {
            if section == 2 {
                return "Select at least one member to create a subgroup"
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEditMode {
            // In edit mode, section 2 is Details, section 3 is Delete
            if indexPath.section == 3 {
                // Delete button cell
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                
                // Style the delete button
                if let deleteButton = cell.contentView.subviews.first(where: { $0 is UIButton }) as? UIButton {
                    deleteButton.layer.cornerRadius = 12
                    deleteButton.layer.masksToBounds = true
                }
                
                return cell
            }
        } else {
            // In create mode, section 2 is Members
            if indexPath.section == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath)
                let member = tripMembers[indexPath.row]
                
                // Configure avatar view
                if let avatarView = cell.contentView.viewWithTag(100) {
                    avatarView.backgroundColor = .systemGray4
                    avatarView.layer.cornerRadius = 25
                }
                
                // Configure name label
                if let nameLabel = cell.contentView.viewWithTag(101) as? UILabel {
                    nameLabel.text = member.fullName
                }
                
                // Configure checkmark
                cell.accessoryType = selectedMemberIds.contains(member.id) ? .checkmark : .none
                
                return cell
            }
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            let member = tripMembers[indexPath.row]
            
            if selectedMemberIds.contains(member.id) {
                selectedMemberIds.remove(member.id)
            } else {
                selectedMemberIds.insert(member.id)
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEditMode {
            switch indexPath.section {
            case 0:
                return indexPath.row == 0 ? 50 : 100 // Name field, Description text view
            case 1:
                return 180 // Color buttons grid
            case 2:
                return 50 // Details cells
            case 3:
                return 60 // Delete button
            default:
                return 44
            }
        } else {
            switch indexPath.section {
            case 0:
                return indexPath.row == 0 ? 50 : 100 // Name field, Description text view
            case 1:
                return 180 // Color buttons grid
            case 2:
                return 70 // Member cells
            default:
                return 44
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension CS04_SubgroupFormVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description (Optional)"
            textView.textColor = .placeholderText
        }
    }
}
