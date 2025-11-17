//
//  Message.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation

struct Message: Codable {
    let id: UUID
    var content: String
    var senderUserId: UUID
    var tripId: UUID
    var subgroupId: UUID?
    var timestamp: Date
    var isAnnouncement: Bool
    var announcementTitle: String?
    var sendNotification: Bool
    
    init(content: String, senderUserId: UUID, tripId: UUID, subgroupId: UUID?, isAnnouncement: Bool = false) {
        self.id = UUID()
        self.content = content
        self.senderUserId = senderUserId
        self.tripId = tripId
        self.subgroupId = subgroupId
        self.timestamp = Date()
        self.isAnnouncement     = isAnnouncement
        self.sendNotification = false
    }
}
