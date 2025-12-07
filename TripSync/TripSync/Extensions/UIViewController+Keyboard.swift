//
//  UIViewController+Keyboard.swift
//  TripSync
//
//  Created by Arpit Garg on 07/12/25.
//

import UIKit

// MARK: - Keyboard Handling Extension
extension UIViewController {
    
    // MARK: - Private Keys
    private struct AssociatedKeys {
        static var tapGesture = "tapGesture"
        static var keyboardHandler = "keyboardHandler"
        static var originalViewFrame = "originalViewFrame"
        static var textFieldDelegate = "textFieldDelegate"
    }
    
    private var tapGesture: UITapGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.tapGesture) as? UITapGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.tapGesture, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var originalViewFrame: CGRect? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.originalViewFrame) as? CGRect
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.originalViewFrame, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // MARK: - Public Methods
    
    /// Enable automatic keyboard handling with tap-to-dismiss and view adjustment
    func enableKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        self.tapGesture = tap
        
        // Store original frame
        originalViewFrame = view.frame
        
        // Register keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    /// Disable keyboard handling and cleanup
    func disableKeyboardHandling() {
        if let tap = tapGesture {
            view.removeGestureRecognizer(tap)
            self.tapGesture = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// Setup return key navigation for text fields
    /// - Parameter textFields: Array of text fields in the order they should be navigated
    func setupReturnKeyNavigation(textFields: [UITextField]) {
        let delegate = TextFieldNavigationDelegate(textFields: textFields)
        
        for (index, textField) in textFields.enumerated() {
            if index < textFields.count - 1 {
                textField.returnKeyType = .next
            } else {
                textField.returnKeyType = .done
            }
            textField.delegate = delegate
        }
        
        // Store delegate to prevent deallocation
        objc_setAssociatedObject(self, &AssociatedKeys.textFieldDelegate, delegate, .OBJC_ASSOCIATION_RETAIN)
    }
    
    // MARK: - Private Methods
    
    @objc private func dismissKeyboardOnTap() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        // Convert keyboard frame to view's coordinate space
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        
        // Find the active text field
        guard let activeTextField = findActiveTextField(in: view) else {
            return
        }
        
        // Calculate the bottom of the active text field
        let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: view)
        let textFieldBottom = textFieldFrame.maxY
        
        // Calculate keyboard top position
        let keyboardTop = keyboardFrameInView.minY
        
        // Check if text field is covered by keyboard (with some padding)
        let padding: CGFloat = 20
        if textFieldBottom + padding > keyboardTop {
            // Calculate how much to move the view up
            let offset = textFieldBottom + padding - keyboardTop
            
            // Animate view movement
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: UIView.AnimationOptions(rawValue: curve << 16),
                animations: {
                    self.view.frame.origin.y = -(offset)
                }
            )
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
              let originalFrame = originalViewFrame else {
            return
        }
        
        // Reset view to original position
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: {
                self.view.frame.origin.y = originalFrame.origin.y
            }
        )
    }
    
    private func findActiveTextField(in view: UIView) -> UITextField? {
        if let textField = view as? UITextField, textField.isFirstResponder {
            return textField
        }
        
        for subview in view.subviews {
            if let textField = findActiveTextField(in: subview) {
                return textField
            }
        }
        
        return nil
    }
}

// MARK: - Text Field Navigation Delegate
private class TextFieldNavigationDelegate: NSObject, UITextFieldDelegate {
    private let textFields: [UITextField]
    
    init(textFields: [UITextField]) {
        self.textFields = textFields
        super.init()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let currentIndex = textFields.firstIndex(of: textField) else {
            textField.resignFirstResponder()
            return true
        }
        
        let nextIndex = currentIndex + 1
        if nextIndex < textFields.count {
            // Move to next text field
            textFields[nextIndex].becomeFirstResponder()
        } else {
            // Last field, dismiss keyboard
            textField.resignFirstResponder()
        }
        
        return true
    }
}
