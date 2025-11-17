//
//  User 2.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation
import UIKit

struct User: Codable {
    let id: UUID
    var fullName: String
    var email: String
    var profileImage: Data?
    var totalTrips: Int
    var totalMemories: Int
    var totalPhotos: Int
    var createdAt: Date
    var userPreferences: UserPreferences
    
    init(fullName: String, email: String) {
        self.id = UUID()
        self.fullName = fullName
        self.email = email
        self.totalTrips = 0
        self.totalMemories = 0
        self.totalPhotos = 0
        self.createdAt = Date()
        self.userPreferences = UserPreferences(
            userId: self.id,
            shareLocation: .allTrips,
            showApproximateLocation: false
        )
    }
    
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}
