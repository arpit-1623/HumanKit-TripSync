//
//  TripMembership.swift
//  TripSync
//
//  Created by Arpit Garg on 08/12/25.
//

import Foundation

enum TripMemberRole {
    case admin
    case member
    case guest // we aren't using this right now, but might required if we want to add the functionality
}

struct TripMembership {
    let userId: UUID
    let tripId: UUID
    let isJoined: Bool?
    var joinedAt: Date?
    var role: TripMemberRole
}

extension Trip {
    func isUserMember(_ userId: UUID) -> Bool {
        return memberIds.contains(userId)
    }
    
    func canUserAccess(_ userId: UUID) -> Bool {
        return memberIds.contains(userId)
        
        // keeping it same for now, might need to change for backend integration
    }
    
    func isUserAdmin(_ userId: UUID) -> Bool {
        return createdByUserId == userId
    }
}
