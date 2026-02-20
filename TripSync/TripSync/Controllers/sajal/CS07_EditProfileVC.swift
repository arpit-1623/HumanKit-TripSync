//
//  CS07_EditProfileVC.swift
//  TripSync
//
//  Created for issue #24 — Edit profile screen for changing name and profile photo.
//  UI is defined in SA08_EditProfile.storyboard (static UITableViewController).
//

import UIKit

class EditProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlets (connected in SA08_EditProfile.storyboard)
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    
    // MARK: - Properties
    private var user: User?
    private var selectedImage: UIImage?
    private var hasChanges: Bool {
        guard let user = user else { return false }
        let nameChanged = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != user.fullName
        let photoChanged = selectedImage != nil
        return nameChanged || photoChanged
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Profile image tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Text field delegate
        nameTextField.delegate = self
    }
    
    private func loadUserData() {
        user = DataModel.shared.getCurrentUser()
        guard let user = user else { return }
        
        nameTextField.text = user.fullName
        emailLabel.text = user.email
        
        // Profile image
        if let imageData = user.profileImage, let image = UIImage(data: imageData) {
            profileImageView.image = image
        } else {
            profileImageView.image = nil
            profileImageView.backgroundColor = generateColor(from: user.fullName)
            addInitialsOverlay(for: user)
        }
    }
    
    // MARK: - Actions
    @IBAction func changePhotoTapped() {
        let alert = UIAlertController(title: "Change Profile Photo", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }
        
        if user?.profileImage != nil || selectedImage != nil {
            alert.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { [weak self] _ in
                self?.removePhoto()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @IBAction func saveTapped() {
        guard var user = user else { return }
        
        let newName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !newName.isEmpty else {
            let alert = UIAlertController(title: "Invalid Name", message: "Name cannot be empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Update user data
        user.fullName = newName
        
        if let selectedImage = selectedImage {
            user.profileImage = selectedImage.jpegData(compressionQuality: 0.8)
        }
        
        // Save to DataModel
        DataModel.shared.saveUser(user)
        DataModel.shared.setCurrentUser(user)
        self.user = user
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Image Picker
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            profileImageView.image = editedImage
            profileImageView.subviews.forEach { $0.removeFromSuperview() }
            profileImageView.backgroundColor = .clear
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            profileImageView.image = originalImage
            profileImageView.subviews.forEach { $0.removeFromSuperview() }
            profileImageView.backgroundColor = .clear
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func removePhoto() {
        guard var user = user else { return }
        user.profileImage = nil
        selectedImage = nil
        
        DataModel.shared.saveUser(user)
        DataModel.shared.setCurrentUser(user)
        self.user = user
        
        profileImageView.image = nil
        profileImageView.backgroundColor = generateColor(from: user.fullName)
        addInitialsOverlay(for: user)
    }
    
    private func addInitialsOverlay(for user: User) {
        profileImageView.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.text = user.initials
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    private func generateColor(from name: String) -> UIColor {
        let colors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange,
            .systemPink, .systemPurple, .systemTeal,
            .systemIndigo, .systemBrown
        ]
        let hash = name.hash
        let index = abs(hash) % colors.count
        return colors[index]
    }
}

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
