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
    var createdAt: Date
    var updatedAt: Date?
    
    init(name: String, description: String?, colorHex: String, tripId: UUID, memberIds: [UUID]) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.colorHex = colorHex
        self.tripId = tripId
        self.memberIds = memberIds
        self.createdAt = Date()
        self.updatedAt = createdAt
    }
    
    var color: UIColor {
        return UIColor(hex: colorHex) ?? .systemBlue
    }
}
