//
//  Subgroup.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation
import UIKit

struct Subgroup: Codable {
    let id: UUID
    var name: String
    var description: String?
    var colorHex: String
    var tripId: UUID
    var memberIds: [UUID]
    var createdByUserId: UUID
    var createdAt: Date
    var updatedAt: Date?
    
    init(name: String, description: String?, colorHex: String, tripId: UUID, memberIds: [UUID], createdByUserId: UUID) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.colorHex = colorHex
        self.tripId = tripId
        self.memberIds = memberIds
        self.createdByUserId = createdByUserId
        self.createdAt = Date()
        self.updatedAt = createdAt
    }
    
    init(id: UUID, name: String, description: String?, colorHex: String, tripId: UUID, memberIds: [UUID], createdByUserId: UUID) {
        self.id = id
        self.name = name
        self.description = description
        self.colorHex = colorHex
        self.tripId = tripId
        self.memberIds = memberIds
        self.createdByUserId = createdByUserId
        self.createdAt = Date()
        self.updatedAt = createdAt
    }
    
    // Backward compatibility: decode old data that doesn't have createdByUserId
    // Falls back to the first member ID or a nil UUID
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        colorHex = try container.decode(String.self, forKey: .colorHex)
        tripId = try container.decode(UUID.self, forKey: .tripId)
        memberIds = try container.decode([UUID].self, forKey: .memberIds)
        createdByUserId = try container.decodeIfPresent(UUID.self, forKey: .createdByUserId) ?? memberIds.first ?? UUID()
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
    
    var color: UIColor {
        return UIColor(hex: colorHex) ?? .systemBlue
    }
}
