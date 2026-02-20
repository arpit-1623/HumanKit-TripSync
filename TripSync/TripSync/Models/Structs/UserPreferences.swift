//
//  UserPreferences.swift
//  TripSync-DataModels
//
//  Created by Arpit Garg on 11/11/25.
//

import Foundation

enum ShareLocationMode: String, Codable {
    case off
    case tripOnly
    case allTrips
}



struct UserPreferences: Codable {
    let userId: UUID
    var shareLocation: ShareLocationMode
    var faceIdEnabled: Bool
    var locationSharingDuration: LocationSharingDuration?
    var locationSharingExpiresAt: Date?
    
    init(userId: UUID, shareLocation: ShareLocationMode, faceIdEnabled: Bool = false) {
        self.userId = userId
        self.shareLocation = shareLocation
        self.faceIdEnabled = faceIdEnabled
        self.locationSharingDuration = nil
        self.locationSharingExpiresAt = nil
    }
    
    // Backward compatibility: decode old data that had showApproximateLocation instead of faceIdEnabled
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(UUID.self, forKey: .userId)
        shareLocation = try container.decode(ShareLocationMode.self, forKey: .shareLocation)
        faceIdEnabled = try container.decodeIfPresent(Bool.self, forKey: .faceIdEnabled) ?? false
        locationSharingDuration = try container.decodeIfPresent(LocationSharingDuration.self, forKey: .locationSharingDuration)
        locationSharingExpiresAt = try container.decodeIfPresent(Date.self, forKey: .locationSharingExpiresAt)
    }
    
    /// Returns true if location sharing is currently active (enabled + not expired)
    var isLocationSharingActive: Bool {
        guard shareLocation != .off else { return false }
        if let expiresAt = locationSharingExpiresAt {
            return expiresAt > Date()
        }
        // If no expiry set and sharing is on, it's active (untilDisabled)
        return true
    }
    
    /// Returns the remaining time for location sharing, or nil if not applicable
    var locationSharingTimeRemaining: TimeInterval? {
        guard isLocationSharingActive, let expiresAt = locationSharingExpiresAt else { return nil }
        let remaining = expiresAt.timeIntervalSinceNow
        return remaining > 0 ? remaining : nil
    }
    
    /// Formatted string of remaining location sharing time (e.g. "2h 15m remaining")
    var locationSharingRemainingText: String? {
        guard let remaining = locationSharingTimeRemaining else { return nil }
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        } else {
            return "\(minutes)m remaining"
        }
    }
}
