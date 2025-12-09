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
    var showApproximateLocation: Bool
    
    init(userId: UUID, shareLocation: ShareLocationMode, showApproximateLocation: Bool) {
        self.userId = userId
        self.shareLocation = shareLocation
        self.showApproximateLocation = showApproximateLocation
    }
}
