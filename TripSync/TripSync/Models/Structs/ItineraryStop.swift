//
//  ItineraryStop.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation

struct ItineraryStop: Codable {
    let id: UUID
    var title: String
    var location: String
    var address: String
    var date: Date
    var time: Date
    var tripId: UUID
    var subgroupId: UUID? // -
    var createdByUserId: UUID
    var isInMyItinerary: Bool
    var addedToMyItineraryByUserId: UUID?
    var isCreatedInMySubgroup: Bool // true if created directly in MY subgroup (private)
    var category: String? // SF Symbol name for category icon
    
    init(title: String, location: String, address: String, date: Date, time: Date, tripId: UUID, subgroupId: UUID?, createdByUserId: UUID, isInMyItinerary: Bool = false, addedToMyItineraryByUserId: UUID? = nil, isCreatedInMySubgroup: Bool = false, category: String? = nil) {
        self.id = UUID()
        self.title = title
        self.location = location
        self.address = address
        self.date = date
        self.time = time
        self.tripId = tripId
        self.subgroupId = subgroupId
        self.createdByUserId = createdByUserId
        self.isInMyItinerary = isInMyItinerary
        self.addedToMyItineraryByUserId = addedToMyItineraryByUserId
        self.isCreatedInMySubgroup = isCreatedInMySubgroup
        self.category = category
    }
    
    init(id: UUID, title: String, location: String, address: String, date: Date, time: Date, tripId: UUID, subgroupId: UUID?, createdByUserId: UUID, isInMyItinerary: Bool = false, addedToMyItineraryByUserId: UUID? = nil, isCreatedInMySubgroup: Bool = false, category: String? = nil) {
        self.id = id
        self.title = title
        self.location = location
        self.address = address
        self.date = date
        self.time = time
        self.tripId = tripId
        self.subgroupId = subgroupId
        self.createdByUserId = createdByUserId
        self.isInMyItinerary = isInMyItinerary
        self.addedToMyItineraryByUserId = addedToMyItineraryByUserId
        self.isCreatedInMySubgroup = isCreatedInMySubgroup
        self.category = category
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        return formatter.string(from: date)
    }
}
