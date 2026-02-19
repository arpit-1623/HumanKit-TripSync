//
//  CA15_SignupVC.swift
//  TripSync
//
//  Created by Arpit Garg on 07/12/25.
//

import UIKit

class CA15_SignupVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
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
        fullNameTextField.autocapitalizationType = .words
        fullNameTextField.autocorrectionType = .no
        
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.autocapitalizationType = .none
        confirmPasswordTextField.autocorrectionType = .no
        
        // Enable keyboard handling
        enableKeyboardHandling()
        setupReturnKeyNavigation(textFields: [
            fullNameTextField,
            emailTextField,
            passwordTextField,
            confirmPasswordTextField
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableKeyboardHandling()
    }
    
    // MARK: - IBActions
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let fullName = fullNameTextField.text?.trimmingCharacters(in: .whitespaces),
              let email = emailTextField.text?.trimmingCharacters(in: .whitespaces),
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            showError("Please fill in all fields.")
            return
        }
        
        // Validate passwords match
        guard password == confirmPassword else {
            showError("Passwords do not match.")
            return
        }
        
        // Attempt signup
        let result = AuthService.shared.signUp(fullName: fullName, email: email, password: password)
        
        switch result {
        case .success(let user):
            print("Signup successful for user: \(user.fullName)")
            navigateToMainApp()
            
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    @IBAction func backToLoginButtonTapped(_ sender: UIButton) {
        // Navigate to login screen by replacing self in the nav stack
        guard let navController = navigationController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "CA14_LoginVC") as? CA14_LoginVC {
            var viewControllers = navController.viewControllers
            viewControllers.removeLast() // Remove SignupVC
            viewControllers.append(loginVC)
            navController.setViewControllers(viewControllers, animated: true)
        }
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
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        
        // Load main storyboard and set tab bar as root
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            window.rootViewController = tabBarController
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
