//
//  CA14_LoginVC.swift
//  TripSync
//
//  Created by Arpit Garg on 07/12/25.
//

import UIKit

class CA14_LoginVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        errorLabel.isHidden = true
        errorLabel.textColor = .systemRed
        
        // Configure text fields
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        
        // Enable keyboard handling
        enableKeyboardHandling()
        setupReturnKeyNavigation(textFields: [emailTextField, passwordTextField])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableKeyboardHandling()
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespaces),
              let password = passwordTextField.text else {
            showError("Please enter email and password.")
            return
        }
        
        // Attempt login
        let result = AuthService.shared.login(email: email, password: password)
        
        switch result {
        case .success(let user):
            print("Login successful for user: \(user.fullName)")
            navigateToMainApp()
            
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        // Navigate to signup screen
        performSegue(withIdentifier: "showSignup", sender: nil)
    }
    
    // MARK: - Helper Methods
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        
        // Hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.errorLabel.isHidden = true
        }
    }
    
    private func navigateToMainApp() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            return
        }
        
        // Mark user as returning (no longer first time)
        if AuthService.shared.isFirstTimeUser() {
            AuthService.shared.markUserAsReturning()
        }
        
        // Use centralized navigation logic from SceneDelegate
        sceneDelegate.navigateBasedOnUserState()
    }
}
