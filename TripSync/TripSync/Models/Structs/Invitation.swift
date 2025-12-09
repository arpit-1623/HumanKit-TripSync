//
//  InvitationStatus.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation

enum InvitationStatus: String, Codable {
    case pending
    case accepted
    case declined
}

enum InvitationType: String, Codable {
    case trip
    case subgroup
}

struct Invitation: Codable {
    let id: UUID
    var type: InvitationType
    var tripId: UUID?
    var subgroupId: UUID?
    var invitedByUserId: UUID
    var invitedUserId: UUID
    var status: InvitationStatus
    var createdAt: Date
    
    init(type: InvitationType, tripId: UUID?, subgroupId: UUID?, invitedByUserId: UUID, invitedUserId: UUID) {
        self.id = UUID()
        self.type = type
        self.tripId = tripId
        self.subgroupId = subgroupId
        self.invitedByUserId = invitedByUserId
        self.invitedUserId = invitedUserId
        self.status = .pending
        self.createdAt = Date()
    }
}
