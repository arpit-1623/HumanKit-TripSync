//
//  Memory.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation

struct Memory: Codable {
    let id: UUID
    var tripId: UUID
    var photoData: [Data]
    var notes: String?
    var date: Date
    
    init(tripId: UUID, photoData: [Data], notes: String?) {
        self.id = UUID()
        self.tripId = tripId
        self.photoData = photoData
        self.notes = notes
        self.date = Date()
    }
}
