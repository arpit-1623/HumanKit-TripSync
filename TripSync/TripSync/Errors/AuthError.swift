//
//  AuthError.swift
//  TripSync
//
//  Created by Arpit Garg on 08/12/25.
//

import Foundation

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
