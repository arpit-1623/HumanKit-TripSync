//
//  TripStatus.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation

enum TripStatus: String, Codable {
    case current
    case upcoming
    case past
}

struct Trip: Codable {
    let id: UUID
    var name: String
    var location: String
    var startDate: Date
    var endDate: Date
    var coverImageData: Data? // Deprecated: kept for backward compatibility
    var coverImageURL: String? // Unsplash image URL
    var coverImagePhotographerName: String? // Photographer attribution for Unsplash
    var inviteCode: String
    var createdAt: Date
    var createdByUserId: UUID
    var memberIds: [UUID]
    var status: TripStatus
    var subgroupIds: [UUID]
    var itineraryStopIds: [UUID]
    var memoryIds: [UUID]

    var memberCount: Int {
        return memberIds.count
    }
    
    init(name: String, location: String, startDate: Date, endDate: Date, createdByUserId: UUID) {
        self.id = UUID()
        self.name = name
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.inviteCode = Trip.generateInviteCode()
        self.createdAt = Date()
        self.createdByUserId = createdByUserId
        self.memberIds = [createdByUserId]
        
        // Calculate status based on dates
        let now = Date()
        if startDate > now {
            self.status = .upcoming
        } else if endDate < now {
            self.status = .past
        } else {
            self.status = .current
        }
        
        self.subgroupIds = []
        self.itineraryStopIds = []
        self.memoryIds = []
    }
    
    static func generateInviteCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in letters.randomElement()! })
    }
    
    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    var numberOfDays: Int {
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}
