//
//  CM01_CreateAccountVC.swift
//  TripSync
//
//  Created on 4 December 2025.
//

import UIKit

class CM01_CreateAccountVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardHandling()
        setupTextFieldDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard when tapping outside text fields
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFieldDelegates() {
        // Find all text fields in the view hierarchy and set their delegates
        findTextFields(in: view).forEach { textField in
            textField.delegate = self
        }
    }
    
    private func findTextFields(in view: UIView) -> [UITextField] {
        var textFields: [UITextField] = []
        for subview in view.subviews {
            if let textField = subview as? UITextField {
                textFields.append(textField)
            } else {
                textFields.append(contentsOf: findTextFields(in: subview))
            }
        }
        return textFields
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView else {
            return
        }
        
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension CM01_CreateAccountVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = findTextFields(in: view)
        
        if let currentIndex = textFields.firstIndex(of: textField) {
            if currentIndex < textFields.count - 1 {
                // Move to next text field
                textFields[currentIndex + 1].becomeFirstResponder()
            } else {
                // Last field - dismiss keyboard
                textField.resignFirstResponder()
            }
        }
        
        return true
    }
}
