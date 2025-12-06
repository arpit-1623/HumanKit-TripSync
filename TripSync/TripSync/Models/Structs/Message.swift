//
//  Message.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation
import UIKit

enum AnnouncementPriority: String, Codable {
    case veryImportant = "Very Important"
    case important = "Important"
    case general = "General"
    
    var color: UIColor {
        switch self {
        case .veryImportant:
            return .systemRed
        case .important:
            return .systemYellow
        case .general:
            return .systemBlue
        }
    }
    
    var icon: String {
        switch self {
        case .veryImportant:
            return "exclamationmark.3"
        case .important:
            return "exclamationmark.2"
        case .general:
            return "info.circle.fill"
        }
    }
}

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
    var priority: AnnouncementPriority
    
    init(content: String, senderUserId: UUID, tripId: UUID, subgroupId: UUID?, isAnnouncement: Bool = false, priority: AnnouncementPriority = .general) {
        self.id = UUID()
        self.content = content
        self.senderUserId = senderUserId
        self.tripId = tripId
        self.subgroupId = subgroupId
        self.timestamp = Date()
        self.isAnnouncement = isAnnouncement
        self.sendNotification = false
        self.priority = priority
    }
}
