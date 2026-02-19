//
//  DataManager.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation

enum DataModelError: LocalizedError {
    case invalidTripName
    case invalidDateRange
    case saveFailed(String)
    case dateOverlap(existingTripName: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidTripName:
            return "Trip name cannot be empty."
        case .invalidDateRange:
            return "Start date must be before or equal to end date."
        case .saveFailed(let message):
            return "Failed to save data: \(message)"
        case .dateOverlap(let existingTripName):
            return "Looks like your trip '\(existingTripName)' falls on the same dates. Please pick a different date range to continue."
        }
    }
}

class DataModel {
    
    // MARK: - Singleton
    static let shared = DataModel()
    
    private let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // File URLs
    private let currentUserURL: URL
    private let tripsURL: URL
    private let subgroupsURL: URL
    private let itineraryStopsURL: URL
    private let messagesURL: URL
    private let locationsURL: URL
    private let invitationsURL: URL

    private let usersURL: URL
    
    // MARK: - Properties
    private var currentUser: User?
    private var users: [User] = []
    private var trips: [Trip] = []
    private var subgroups: [Subgroup] = []
    private var itineraryStops: [ItineraryStop] = []
    private var messages: [Message] = []
    private var locations: [UserLocation] = []
    private var invitations: [Invitation] = []

    
    private init() {
        currentUserURL = documentDir.appendingPathComponent("current_user_data").appendingPathExtension("json")
        tripsURL = documentDir.appendingPathComponent("trips_data").appendingPathExtension("json")
        subgroupsURL = documentDir.appendingPathComponent("subgroups_data").appendingPathExtension("json")
        itineraryStopsURL = documentDir.appendingPathComponent("itinerary_stops_data").appendingPathExtension("json")
        messagesURL = documentDir.appendingPathComponent("messages_data").appendingPathExtension("json")
        locationsURL = documentDir.appendingPathComponent("locations_data").appendingPathExtension("json")
        invitationsURL = documentDir.appendingPathComponent("invitations_data").appendingPathExtension("json")

        usersURL = documentDir.appendingPathComponent("users_data").appendingPathExtension("json")
        
        loadData()
    }
    
    // MARK: - Load Data
    
    private func loadData() {
        currentUser = loadCurrentUserFromFile()
        users = loadUsersFromFile() 
        trips = loadTripsFromFile()
        subgroups = loadSubgroupsFromFile()
        itineraryStops = loadItineraryStopsFromFile()
        messages = loadMessagesFromFile()
        locations = loadLocationsFromFile()
        invitations = loadInvitationsFromFile()

    }
    
    // MARK: - User Data Model
    
    private func loadCurrentUserFromFile() -> User? {
        guard FileManager.default.fileExists(atPath: currentUserURL.path),
              let data = try? Data(contentsOf: currentUserURL),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    private func saveCurrentUserToFile() {
        do {
            if let user = currentUser {
                let data = try JSONEncoder().encode(user)
                try data.write(to: currentUserURL, options: .atomic)
            } else {
                try FileManager.default.removeItem(at: currentUserURL)
            }
        } catch {
            print("Error saving current user to file: \(error.localizedDescription)")
        }
    }
    
    public func getCurrentUser() -> User? {
        return currentUser
    }
    
    public func setCurrentUser(_ user: User?) {
        currentUser = user
        saveCurrentUserToFile()
    }
    
    private func loadUsersFromFile() -> [User] {
        guard FileManager.default.fileExists(atPath: usersURL.path),
              let data = try? Data(contentsOf: usersURL),
              let loadedUsers = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return loadedUsers
    }
    
    private func saveUsersToFile() {
        do {
            let data = try JSONEncoder().encode(users)
            try data.write(to: usersURL, options: .atomic)
        } catch {
            print("Error saving users to file: \(error.localizedDescription)")
        }
    }
    
    public func saveUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        } else {
            users.append(user)
        }
        saveUsersToFile()
    }
    
    public func getAllUsers() -> [User] {
        return users
    }
    
    public func getUser(byId id: UUID) -> User? {
        return users.first(where: { $0.id == id })
    }
    
    public func deleteUser(byId id: UUID) {
        users.removeAll(where: { $0.id == id })
        saveUsersToFile()
    }
    
    // MARK: - Trip Data Model
    
    private func loadTripsFromFile() -> [Trip] {
        guard FileManager.default.fileExists(atPath: tripsURL.path),
              let data = try? Data(contentsOf: tripsURL),
              let loadedTrips = try? JSONDecoder().decode([Trip].self, from: data) else {
            return []
        }
        return loadedTrips
    }
    
    private func saveTripsToFile() {
        do {
            let data = try JSONEncoder().encode(trips)
            try data.write(to: tripsURL, options: .atomic)
        } catch {
            print("Error saving trips to file: \(error.localizedDescription)")
        }
    }
    
    public func saveTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
        } else {
            trips.append(trip)
        }
        saveTripsToFile()
    }
    
    /// Checks if a date range conflicts with any existing trip the user is a member of.
    /// - Parameters:
    ///   - userId: The user to check for
    ///   - startDate: Start of the proposed date range
    ///   - endDate: End of the proposed date range
    ///   - excludingTripId: Trip ID to exclude (for edit scenarios)
    /// - Returns: The first conflicting trip, or nil
    public func findOverlappingTrip(forUserId userId: UUID, startDate: Date, endDate: Date, excludingTripId: UUID? = nil) -> Trip? {
        return trips.first { trip in
            trip.memberIds.contains(userId) &&
            trip.id != excludingTripId &&
            startDate <= trip.endDate &&
            endDate >= trip.startDate
        }
    }
    
    public func saveTripWithValidation(_ trip: Trip) throws {
        // Validate trip data
        guard !trip.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DataModelError.invalidTripName
        }
        
        guard trip.startDate <= trip.endDate else {
            throw DataModelError.invalidDateRange
        }
        
        // Check for date overlap with existing trips
        if let overlapping = findOverlappingTrip(forUserId: trip.createdByUserId, startDate: trip.startDate, endDate: trip.endDate, excludingTripId: trip.id) {
            throw DataModelError.dateOverlap(existingTripName: overlapping.name)
        }
        
        // Save the trip
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
        } else {
            trips.append(trip)
        }
        
        // Attempt to save to file
        do {
            let data = try JSONEncoder().encode(trips)
            try data.write(to: tripsURL, options: .atomic)
        } catch {
            // Rollback the change if save failed
            trips.removeAll(where: { $0.id == trip.id })
            throw DataModelError.saveFailed(error.localizedDescription)
        }
    }
    
    public func getAllTrips() -> [Trip] {
        return trips
    }
    
    public func getTrip(byId id: UUID) -> Trip? {
        return trips.first(where: { $0.id == id })
    }
    
    public func getTrip(byInviteCode inviteCode: String) -> Trip? {
        return trips.first(where: { $0.inviteCode.uppercased() == inviteCode.uppercased() })
    }
    
    public func getTrips(forUserId userId: UUID) -> [Trip] {
        return trips.filter { $0.memberIds.contains(userId) }
    }
    
    public func getUserTrips(forUserId userId: UUID) -> [Trip] {
        return trips.filter { $0.memberIds.contains(userId) }
            .sorted { $0.startDate > $1.startDate }
    }
    
    public func getCurrentTrip() -> Trip? {
        return trips.first(where: { $0.status == .current })
    }
    
    public func getNonCurrentTrips() -> [Trip] {
        return trips.filter { $0.status != .current }
    }
    
    public func getUpcomingTrips() -> [Trip] {
        return trips.filter { $0.status == .upcoming }
    }
    
    public func getPastTrips() -> [Trip] {
        return trips.filter { $0.status == .past }
    }
    
    public func getMyTrips(_ userId: UUID) -> [Trip] {
        return trips.filter{ $0.createdByUserId == userId }
    }
    
    public func deleteTrip(byId id: UUID) {
        trips.removeAll(where: { $0.id == id })
        saveTripsToFile()
        
        // Delete Data Related to the Trip
        deleteSubgroups(forTripId: id)
        deleteItineraryStops(forTripId: id)
        deleteMessages(forTripId: id)
        deleteLocations(forTripId: id)

        deleteInvitations(forTripId: id)
    }
    
    public func removeMemberFromTrip(tripId: UUID, memberId: UUID) -> Bool {
        guard var trip = getTrip(byId: tripId),
              let currentUser = getCurrentUser(),
              trip.isUserAdmin(currentUser.id),
              memberId != currentUser.id else {
            return false
        }
        
        trip.memberIds.removeAll { $0 == memberId }
        
        do {
            try saveTrip(trip)
            return true
        } catch {
            return false
        }
    }
    
    public func leaveTrip(tripId: UUID) -> Bool {
        guard var trip = getTrip(byId: tripId),
              let currentUser = getCurrentUser(),
              !trip.isUserAdmin(currentUser.id),
              trip.memberIds.contains(currentUser.id) else {
            return false
        }
        
        trip.memberIds.removeAll { $0 == currentUser.id }
        
        do {
            try saveTrip(trip)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Subgroup Data Model
    private func loadSubgroupsFromFile() -> [Subgroup] {
        guard FileManager.default.fileExists(atPath: subgroupsURL.path),
              let data = try? Data(contentsOf: subgroupsURL),
              let loadedSubgroups = try? JSONDecoder().decode([Subgroup].self, from: data) else {
            return []
        }
        return loadedSubgroups
    }
    
    private func saveSubgroupsToFile() {
        do {
            let data = try JSONEncoder().encode(subgroups)
            try data.write(to: subgroupsURL, options: .atomic)
        } catch {
            print("Error saving subgroups to file: \(error.localizedDescription)")
        }
    }
    
    public func saveSubgroup(_ subgroup: Subgroup) {
        if let index = subgroups.firstIndex(where: { $0.id == subgroup.id }) {
            subgroups[index] = subgroup
        } else {
            subgroups.append(subgroup)
            if var trip = getTrip(byId: subgroup.tripId) {
                if !trip.subgroupIds.contains(subgroup.id) {
                    trip.subgroupIds.append(subgroup.id)
                    saveTrip(trip)
                }
            }
        }
        saveSubgroupsToFile()
    }
    
    public func getAllSubgroups() -> [Subgroup] {
        return subgroups
    }
    
    public func getSubgroups(forTripId tripId: UUID) -> [Subgroup] {
        return subgroups.filter { $0.tripId == tripId }
    }
    
    public func getSubgroup(byId id: UUID) -> Subgroup? {
        return subgroups.first(where: { $0.id == id })
    }
    
    public func deleteSubgroup(byId id: UUID) {
        guard let subgroup = getSubgroup(byId: id) else { return }
        
        subgroups.removeAll(where: { $0.id == id })
        
        // Remove from trip's subgroupIds
        if var trip = getTrip(byId: subgroup.tripId) {
            trip.subgroupIds.removeAll(where: { $0 == id })
            saveTrip(trip)
        }
        
        saveSubgroupsToFile()
    }
    
    public func deleteSubgroups(forTripId tripId: UUID) {
        subgroups.removeAll(where: { $0.tripId == tripId })
        saveSubgroupsToFile()
    }
    
    // MARK: - Itinerary Data Model
    private func loadItineraryStopsFromFile() -> [ItineraryStop] {
        guard FileManager.default.fileExists(atPath: itineraryStopsURL.path),
              let data = try? Data(contentsOf: itineraryStopsURL),
              let loadedStops = try? JSONDecoder().decode([ItineraryStop].self, from: data) else {
            return []
        }
        return loadedStops
    }
    
    private func saveItineraryStopsToFile() {
        do {
            let data = try JSONEncoder().encode(itineraryStops)
            try data.write(to: itineraryStopsURL, options: .atomic)
        } catch {
            print("Error saving itinerary stops to file: \(error.localizedDescription)")
        }
    }
    
    public func saveItineraryStop(_ stop: ItineraryStop) {
        if let index = itineraryStops.firstIndex(where: { $0.id == stop.id }) {
            itineraryStops[index] = stop
        } else {
            itineraryStops.append(stop)
            // Add to trip's itineraryStopIds
            if var trip = getTrip(byId: stop.tripId) {
                if !trip.itineraryStopIds.contains(stop.id) {
                    trip.itineraryStopIds.append(stop.id)
                    saveTrip(trip)
                }
            }
        }
        saveItineraryStopsToFile()
    }
    
    public func getAllItineraryStops() -> [ItineraryStop] {
        return itineraryStops
    }
    
    public func getItineraryStops(forTripId tripId: UUID) -> [ItineraryStop] {
        return itineraryStops
            .filter { $0.tripId == tripId }
            .sorted { $0.date < $1.date }
    }
    
    public func getItineraryStop(byId id: UUID) -> ItineraryStop? {
        return itineraryStops.first(where: { $0.id == id })
    }
    
    public func deleteItineraryStop(byId id: UUID) {
        guard let stop = getItineraryStop(byId: id) else { return }
        
        itineraryStops.removeAll(where: { $0.id == id })
        
        // Remove from trip's itineraryStopIds
        if var trip = getTrip(byId: stop.tripId) {
            trip.itineraryStopIds.removeAll(where: { $0 == id })
            saveTrip(trip)
        }
        
        saveItineraryStopsToFile()
    }
    
    public func deleteItineraryStops(forTripId tripId: UUID) {
        itineraryStops.removeAll(where: { $0.tripId == tripId })
        saveItineraryStopsToFile()
    }
    
    public func addStopToMyItinerary(_ stopId: UUID, userId: UUID) {
        if let index = itineraryStops.firstIndex(where: { $0.id == stopId }) {
            itineraryStops[index].isInMyItinerary = true
            itineraryStops[index].addedToMyItineraryByUserId = userId
            saveItineraryStopsToFile()
        }
    }
    
    public func removeStopFromMyItinerary(_ stopId: UUID, userId: UUID) {
        if let index = itineraryStops.firstIndex(where: { $0.id == stopId }) {
            itineraryStops[index].isInMyItinerary = false
            itineraryStops[index].addedToMyItineraryByUserId = nil
            saveItineraryStopsToFile()
        }
    }
    
    public func getMyItineraryStops(forUserId userId: UUID, tripId: UUID) -> [ItineraryStop] {
        return itineraryStops
            .filter { $0.tripId == tripId && $0.isInMyItinerary && $0.addedToMyItineraryByUserId == userId }
            .sorted { $0.date < $1.date }
    }
    
    // MARK: - Message Data Model
    
    private func loadMessagesFromFile() -> [Message] {
        guard FileManager.default.fileExists(atPath: messagesURL.path),
              let data = try? Data(contentsOf: messagesURL),
              let loadedMessages = try? JSONDecoder().decode([Message].self, from: data) else {
            return []
        }
        return loadedMessages
    }
    
    private func saveMessagesToFile() {
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: messagesURL, options: .atomic)
        } catch {
            print("Error saving messages to file: \(error.localizedDescription)")
        }
    }
    
    public func saveMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
        } else {
            messages.append(message)
        }
        saveMessagesToFile()
    }
    
    public func getAllMessages() -> [Message] {
        return messages
    }
    
    public func getMessages(forTripId tripId: UUID, subgroupId: UUID?) -> [Message] {
        return messages
            .filter { $0.tripId == tripId && $0.subgroupId == subgroupId }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    public func getMessage(byId id: UUID) -> Message? {
        return messages.first(where: { $0.id == id })
    }
    
    public func deleteMessage(byId id: UUID) {
        messages.removeAll(where: { $0.id == id })
        saveMessagesToFile()
    }
    
    public func deleteMessages(forTripId tripId: UUID) {
        messages.removeAll(where: { $0.tripId == tripId })
        saveMessagesToFile()
    }
    
    // MARK: - Location Data Model
    
    private func loadLocationsFromFile() -> [UserLocation] {
        guard FileManager.default.fileExists(atPath: locationsURL.path),
              let data = try? Data(contentsOf: locationsURL),
              let loadedLocations = try? JSONDecoder().decode([UserLocation].self, from: data) else {
            return []
        }
        return loadedLocations
    }
    
    private func saveLocationsToFile() {
        do {
            let data = try JSONEncoder().encode(locations)
            try data.write(to: locationsURL, options: .atomic)
        } catch {
            print("Error saving locations to file: \(error.localizedDescription)")
        }
    }
    
    public func saveLocation(_ location: UserLocation) {
        if let index = locations.firstIndex(where: { $0.userId == location.userId && $0.tripId == location.tripId }) {
            locations[index] = location
        } else {
            locations.append(location)
        }
        saveLocationsToFile()
    }
    
    public func getAllLocations() -> [UserLocation] {
        return locations
    }
    
    public func getLocations(forTripId tripId: UUID) -> [UserLocation] {
        return locations.filter { $0.tripId == tripId }
    }
    
    public func getLocation(userId: UUID, tripId: UUID) -> UserLocation? {
        return locations.first(where: { $0.userId == userId && $0.tripId == tripId })
    }
    
    public func deleteLocation(userId: UUID, tripId: UUID) {
        locations.removeAll(where: { $0.userId == userId && $0.tripId == tripId })
        saveLocationsToFile()
    }
    
    public func deleteLocations(forTripId tripId: UUID) {
        locations.removeAll(where: { $0.tripId == tripId })
        saveLocationsToFile()
    }
    
    // MARK: - Invitation Data Model
    
    private func loadInvitationsFromFile() -> [Invitation] {
        guard FileManager.default.fileExists(atPath: invitationsURL.path),
              let data = try? Data(contentsOf: invitationsURL),
              let loadedInvitations = try? JSONDecoder().decode([Invitation].self, from: data) else {
            return []
        }
        return loadedInvitations
    }
    
    private func saveInvitationsToFile() {
        do {
            let data = try JSONEncoder().encode(invitations)
            try data.write(to: invitationsURL, options: .atomic)
        } catch {
            print("Error saving invitations to file: \(error.localizedDescription)")
        }
    }
    
    public func saveInvitation(_ invitation: Invitation) {
        if let index = invitations.firstIndex(where: { $0.id == invitation.id }) {
            invitations[index] = invitation
        } else {
            invitations.append(invitation)
        }
        saveInvitationsToFile()
    }
    
    public func getAllInvitations() -> [Invitation] {
        return invitations
    }
    
    public func getPendingInvitations(forUserId userId: UUID) -> [Invitation] {
        return invitations.filter {
            $0.invitedUserId == userId && $0.status == .pending
        }
    }
    
    public func getInvitation(byId id: UUID) -> Invitation? {
        return invitations.first(where: { $0.id == id })
    }
    
    public func updateInvitation(_ invitation: Invitation) {
        if let index = invitations.firstIndex(where: { $0.id == invitation.id }) {
            invitations[index] = invitation
        }
        saveInvitationsToFile()
    }
    
    public func deleteInvitation(byId id: UUID) {
        invitations.removeAll(where: { $0.id == id })
        saveInvitationsToFile()
    }

    public func deleteInvitations(forTripId tripId: UUID) {
        invitations.removeAll(where: { $0.tripId == tripId })
        saveInvitationsToFile()
    }
    
    public func deleteInvitation(_ userId: UUID, tripId: UUID) {
        invitations.removeAll(where: { $0.tripId == tripId && $0.invitedUserId == userId })
    }
    
    public func getInvitations(forSubgroupId subgroupId: UUID, status: InvitationStatus? = nil) -> [Invitation] {
        var filtered = invitations.filter {
            $0.type == .subgroup &&
            $0.subgroupId == subgroupId
        }
        
        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }
        
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }
    

    
    // MARK: - Trip Access Data Model
    public func canUserAccessTrip(_ userId: UUID, tripId: UUID) -> Bool {
        guard let trip = getTrip(byId: tripId) else { return false }
        return trip.memberIds.contains(userId)
    }
    
    public func getUserAccessibleTrips(_ userId: UUID, tripId: UUID) -> Trip? {
        guard canUserAccessTrip(userId, tripId: tripId) else {
            return nil
        }
        
        return getTrip(byId: tripId)
    }
    
    public func getUserAccessibleTrips(_ userId: UUID) -> [Trip] {
        return trips.filter { trip in
            trip.memberIds.contains(userId)
        }.sorted { $0.startDate > $1.startDate }
    }
    
    // MARK: - Join Trip
    public func joinTripWithCode(_ userId: UUID, inviteCode: String) throws -> Trip {
        guard let trip = getTrip(byInviteCode: inviteCode) else {
            throw JoinTripError.invalidCode
        }
        
        guard !trip.memberIds.contains(userId) else {
            throw JoinTripError.alreadyMember
        }
        
        // Check for date overlap with user's existing trips
        if let overlapping = findOverlappingTrip(forUserId: userId, startDate: trip.startDate, endDate: trip.endDate) {
            throw JoinTripError.dateOverlap(existingTripName: overlapping.name)
        }
        
        var updatedTrip = trip
        updatedTrip.memberIds.append(userId)
        
        saveTrip(updatedTrip)
        
        deleteInvitation(userId, tripId: trip.id)
        
        return updatedTrip
    }
    
    public func acceptTripInvitation(_ invitationId: UUID, userId: UUID) throws -> Trip {
        guard var invitation = getInvitation(byId: invitationId) else {
            throw JoinTripError.invitationNotFound
        }
        
        guard invitation.invitedUserId == userId else {
            throw JoinTripError.unauthorizedAccess
        }
        
        guard invitation.status == .pending else {
            throw JoinTripError.invalidInvitationStatus
        }
        
        guard let tripId = invitation.tripId,
              var trip = getTrip(byId: tripId) else {
            throw JoinTripError.tripNotFound
        }
        
        // Check for date overlap with user's existing trips
        if let overlapping = findOverlappingTrip(forUserId: userId, startDate: trip.startDate, endDate: trip.endDate) {
            throw JoinTripError.dateOverlap(existingTripName: overlapping.name)
        }
        
        if !trip.memberIds.contains(userId) {
            trip.memberIds.append(userId)
            saveTrip(trip)
        }
        
        invitation.status = .accepted
        updateInvitation(invitation)
        
        return trip
    }
    
    
}
