//
//  User.swift
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
    var passwordHash: String
    var profileImage: Data?
    var createdAt: Date
    var userPreferences: UserPreferences
    
    init(fullName: String, email: String, passwordHash: String) {
        self.id = UUID()
        self.fullName = fullName
        self.email = email
        self.passwordHash = passwordHash
        self.createdAt = Date()
        self.userPreferences = UserPreferences(
            userId: self.id,
            shareLocation: .allTrips,
            faceIdEnabled: false
        )
    }
    
    // Backward compatibility: old data may have totalTrips, totalMemories, totalPhotos — just ignore them
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        fullName = try container.decode(String.self, forKey: .fullName)
        email = try container.decode(String.self, forKey: .email)
        passwordHash = try container.decode(String.self, forKey: .passwordHash)
        profileImage = try container.decodeIfPresent(Data.self, forKey: .profileImage)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        userPreferences = try container.decode(UserPreferences.self, forKey: .userPreferences)
    }
    
    /// Computed total trips from DataModel
    var totalTrips: Int {
        return DataModel.shared.getUserTrips(forUserId: id).count
    }
    
    /// Computed total photos (placeholder — no photo tracking feature yet)
    var totalPhotos: Int {
        return 0
    }
    
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}
