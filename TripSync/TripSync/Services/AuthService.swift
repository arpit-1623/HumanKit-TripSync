//
//  AuthService.swift
//  TripSync
//
//  Created by Arpit Garg on 07/12/25.
//

import Foundation
import CommonCrypto
import Security

class AuthService {
    
    // MARK: - Singleton
    static let shared = AuthService()
    
    private let authTokenKey = "com.tripsync.authtoken"
    private let sessionExpirationKey = "com.tripsync.sessionexpiration"
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    /// Sign up a new user with email and password
    func signUp(fullName: String, email: String, password: String) -> Result<User, AuthError> {
        // Validate inputs
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.invalidFullName)
        }
        
        guard isValidEmail(email) else {
            return .failure(.invalidEmail)
        }
        
        guard password.count >= 6 else {
            return .failure(.weakPassword)
        }
        
        // Check if email already exists
        let existingUsers = DataModel.shared.getAllUsers()
        if existingUsers.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            return .failure(.emailAlreadyExists)
        }
        
        // Hash password
        let passwordHash = hashPassword(password)
        
        // Create new user
        let newUser = User(fullName: fullName, email: email, passwordHash: passwordHash)
        
        // Save user to data model
        DataModel.shared.saveUser(newUser)
        
        // Set as current user and create session
        DataModel.shared.setCurrentUser(newUser)
        createSession(for: newUser)
        
        return .success(newUser)
    }
    
    /// Log in an existing user with email and password
    func login(email: String, password: String) -> Result<User, AuthError> {
        guard !email.isEmpty, !password.isEmpty else {
            return .failure(.invalidCredentials)
        }
        
        // Find user by email
        let users = DataModel.shared.getAllUsers()
        guard let user = users.first(where: { $0.email.lowercased() == email.lowercased() }) else {
            return .failure(.invalidCredentials)
        }
        
        // Verify password
        let passwordHash = hashPassword(password)
        guard user.passwordHash == passwordHash else {
            return .failure(.invalidCredentials)
        }
        
        // Set as current user and create session
        DataModel.shared.setCurrentUser(user)
        createSession(for: user)
        
        return .success(user)
    }
    
    /// Log out the current user
    func logout() {
        DataModel.shared.setCurrentUser(nil)
        clearSession()
    }
    
    // MARK: - Session Management
    
    /// Check if user has a valid session
    func hasValidSession() -> Bool {
        guard let _ = getAuthToken(),
              let expiration = UserDefaults.standard.object(forKey: sessionExpirationKey) as? Date else {
            return false
        }
        
        // Check if session hasn't expired
        return expiration > Date()
    }
    
    /// Check if user is authenticated
    func isAuthenticated() -> Bool {
        return DataModel.shared.getCurrentUser() != nil && hasValidSession()
    }
    
    /// Create a session for the user (30 days validity)
    private func createSession(for user: User) {
        let token = UUID().uuidString
        let expirationDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        saveAuthToken(token)
        UserDefaults.standard.set(expirationDate, forKey: sessionExpirationKey)
    }
    
    /// Clear the current session
    private func clearSession() {
        deleteAuthToken()
        UserDefaults.standard.removeObject(forKey: sessionExpirationKey)
    }
    
    // MARK: - Keychain Methods
    
    private func saveAuthToken(_ token: String) {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: authTokenKey,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getAuthToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: authTokenKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    private func deleteAuthToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: authTokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Helper Methods
    
    /// Hash password using SHA256
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidFullName
    case invalidEmail
    case weakPassword
    case emailAlreadyExists
    case invalidCredentials
    case sessionExpired
    
    var errorDescription: String? {
        switch self {
        case .invalidFullName:
            return "Please enter a valid full name."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 6 characters long."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .invalidCredentials:
            return "Invalid email or password."
        case .sessionExpired:
            return "Your session has expired. Please log in again."
        }
    }
}
