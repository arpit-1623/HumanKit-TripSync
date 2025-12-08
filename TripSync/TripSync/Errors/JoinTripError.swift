//
//  JoinTripError.swift
//  TripSync
//
//  Created by Arpit Garg on 08/12/25.
//

import Foundation

enum JoinTripError: LocalizedError {
    case invalidCode
    case alreadyMember
    case invitationNotFound
    case unauthorizedAccess
    case invalidInvitationStatus
    case tripNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidCode:
            return "Invalid invite code."
        case .alreadyMember:
            return "You're already a member of this trip."
        case .invitationNotFound:
            return "Invitation not found."
        case .unauthorizedAccess:
            return "You don't have access to this invitation."
        case .invalidInvitationStatus:
            return "This invitation cannot be accepted."
        case .tripNotFound:
            return "Trip not found."
        }
    }
}
