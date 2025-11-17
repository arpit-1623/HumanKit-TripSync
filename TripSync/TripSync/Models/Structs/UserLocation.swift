//
//  UserLocation.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation
import CoreLocation

struct UserLocation: Codable {
    let id: UUID
    var userId: UUID
    var tripId: UUID
    var latitude: Double
    var longitude: Double
    var isLive: Bool
    var timestamp: Date
    
    init(userId: UUID, tripId: UUID, coordinate: CLLocationCoordinate2D, isLive: Bool) {
        self.id = UUID()
        self.userId = userId
        self.tripId = tripId
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.isLive = isLive
        self.timestamp = Date()
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
