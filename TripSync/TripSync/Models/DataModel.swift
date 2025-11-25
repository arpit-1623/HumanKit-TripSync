//
//  DataManager.swift
//  TripSync
//
//  Created by Arpit Garg on 31/10/25.
//


import Foundation

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
    private let memoriesURL: URL
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
    private var memories: [Memory] = []
    
    private init() {
        currentUserURL = documentDir.appendingPathComponent("current_user_data").appendingPathExtension("json")
        tripsURL = documentDir.appendingPathComponent("trips_data").appendingPathExtension("json")
        subgroupsURL = documentDir.appendingPathComponent("subgroups_data").appendingPathExtension("json")
        itineraryStopsURL = documentDir.appendingPathComponent("itinerary_stops_data").appendingPathExtension("json")
        messagesURL = documentDir.appendingPathComponent("messages_data").appendingPathExtension("json")
        locationsURL = documentDir.appendingPathComponent("locations_data").appendingPathExtension("json")
        invitationsURL = documentDir.appendingPathComponent("invitations_data").appendingPathExtension("json")
        memoriesURL = documentDir.appendingPathComponent("memories_data").appendingPathExtension("json")
        usersURL = documentDir.appendingPathComponent("users_data").appendingPathExtension("json")
        
        loadData()
        
        // Populate sample data on first launch
//        if users.isEmpty || trips.isEmpty {
//            SampleData.shared.populateDataModel()
//            loadData()
//        }
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
        memories = loadMemoriesFromFile()
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
        if let user = currentUser {
            guard let data = try? JSONEncoder().encode(user) else { return }
            try? data.write(to: currentUserURL, options: .atomic)
        } else {
            try? FileManager.default.removeItem(at: currentUserURL)
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
        guard let data = try? JSONEncoder().encode(users) else { return }
        try? data.write(to: usersURL, options: .atomic)
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
        guard let data = try? JSONEncoder().encode(trips) else { return }
        try? data.write(to: tripsURL, options: .atomic)
    }
    
    public func saveTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
        } else {
            trips.append(trip)
        }
        saveTripsToFile()
    }
    
    public func getAllTrips() -> [Trip] {
        return trips
    }
    
    public func getTrip(byId id: UUID) -> Trip? {
        return trips.first(where: { $0.id == id })
    }

    public func getTrip(byInviteCode inviteCode: String) -> Trip? {
        return trips.first {
            $0.inviteCode.uppercased() == inviteCode.uppercased()
        }
    }
    
    public func getTrips(forUserId userId: UUID) -> [Trip] {
        return trips.filter { $0.memberIds.contains(userId) }
    }
    
    public func deleteTrip(byId id: UUID) {
        trips.removeAll(where: { $0.id == id })
        saveTripsToFile()
        
        // Delete Data Related to the Trip
        deleteSubgroups(forTripId: id)
        deleteItineraryStops(forTripId: id)
        deleteMessages(forTripId: id)
        deleteLocations(forTripId: id)
        deleteMemories(forTripId: id)
        deleteInvitations(forTripId: id)
    }

    public func addMember(_ userId: UUID, toTripId tripId: UUID) {
        guard var trip = getTrip(byId: tripId) else { return }
        if !trip.memberIds.contains(userId) {
            trip.memberIds.append(userId)
            saveTrip(trip)
        }
    }

    public func removeMember(_ userId: UUID, fromTripId tripId: UUID) {
        guard var trip = getTrip(byId: tripId) else { return }
        trip.memberIds.removeAll { $0 == userId }
        saveTrip(trip)
    }

    public func getCurrentTrip() -> Trip? {
        return trips.first(where: { $0.status == .current })
    }

    public func getNonCurrentTrips() -> [Trip] {
        return trips.filter { $0.status != .current }
    }

    public func getMemberCount(forTripId tripId: UUID) -> Int {
        guard let trip = getTrip(byId: tripId) else { return 0 }
        return trip.memberIds.count
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
        guard let data = try? JSONEncoder().encode(subgroups) else { return }
        try? data.write(to: subgroupsURL, options: .atomic)
    }
    
    public func saveSubgroup(_ subgroup: Subgroup) {
        if let index = subgroups.firstIndex(where: { $0.id == subgroup.id }) {
            subgroups[index] = subgroup
        } else {
            subgroups.append(subgroup)
            // Add to trip's subgroupIds
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
    
    public func deleteSubgroup(_ subgroup: Subgroup) {
        deleteSubgroup(byId: subgroup.id)
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

    public func addMember(_ userId: UUID, toSubgroupId subgroupId: UUID) {
        guard var subgroup = getSubgroup(byId: subgroupId) else { return }
        if !subgroup.memberIds.contains(userId) {
            subgroup.memberIds.append(userId)
            saveSubgroup(subgroup)
        }
    }

    public func removeMember(_ userId: UUID, fromSubgroupId subgroupId: UUID) {
        guard var subgroup = getSubgroup(byId: subgroupId) else { return }
        subgroup.memberIds.removeAll { $0 == userId }
        saveSubgroup(subgroup)
    }

    public func getMemberCount(forSubgroupId subgroupId: UUID) -> Int {
        guard let subgroup = getSubgroup(byId: subgroupId) else { return 0 }
        return subgroup.memberIds.count
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
        guard let data = try? JSONEncoder().encode(itineraryStops) else { return }
        try? data.write(to: itineraryStopsURL, options: .atomic)
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
    
    public func getItineraryStops(forTripId tripId: UUID,
                                  subgroupId: UUID?) -> [ItineraryStop] {
        return itineraryStops.filter { stop in
            guard stop.tripId == tripId else { return false }
            if let subgroupId = subgroupId {
                return stop.subgroupId == subgroupId
            } else {
                return true
            }
        }
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
        guard let data = try? JSONEncoder().encode(messages) else { return }
        try? data.write(to: messagesURL, options: .atomic)
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
        guard let data = try? JSONEncoder().encode(locations) else { return }
        try? data.write(to: locationsURL, options: .atomic)
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
        guard let data = try? JSONEncoder().encode(invitations) else { return }
        try? data.write(to: invitationsURL, options: .atomic)
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
    
    public func getInvitations(forTripId tripId: UUID) -> [Invitation] {
        return invitations.filter { $0.tripId == tripId }
    }
    
    public func getInvitation(byId id: UUID) -> Invitation? {
        return invitations.first(where: { $0.id == id })
    }
    
    public func updateInvitationStatus(id: UUID, to status: InvitationStatus) {
        guard let idx = invitations.firstIndex(where: { $0.id == id }) else { return }
        invitations[idx].status = status
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
    
    // MARK: - Memory Data Model
    
    private func loadMemoriesFromFile() -> [Memory] {
        guard FileManager.default.fileExists(atPath: memoriesURL.path),
              let data = try? Data(contentsOf: memoriesURL),
              let loadedMemories = try? JSONDecoder().decode([Memory].self, from: data) else {
            return []
        }
        return loadedMemories
    }
    
    private func saveMemoriesToFile() {
        guard let data = try? JSONEncoder().encode(memories) else { return }
        try? data.write(to: memoriesURL, options: .atomic)
    }
    
    public func saveMemory(_ memory: Memory) {
        if let index = memories.firstIndex(where: { $0.id == memory.id }) {
            memories[index] = memory
        } else {
            memories.append(memory)
            // Add to trip's memoryIds
            if var trip = getTrip(byId: memory.tripId) {
                if !trip.memoryIds.contains(memory.id) {
                    trip.memoryIds.append(memory.id)
                    saveTrip(trip)
                }
            }
        }
        saveMemoriesToFile()
    }
    
    public func getAllMemories() -> [Memory] {
        return memories
    }
    
    public func getMemories(forTripId tripId: UUID) -> [Memory] {
        return memories.filter { $0.tripId == tripId }
    }
    
    public func getMemory(byId id: UUID) -> Memory? {
        return memories.first(where: { $0.id == id })
    }
    
    public func deleteMemory(byId id: UUID) {
        guard let memory = getMemory(byId: id) else { return }
        
        memories.removeAll(where: { $0.id == id })
        
        // Remove from trip's memoryIds
        if var trip = getTrip(byId: memory.tripId) {
            trip.memoryIds.removeAll(where: { $0 == id })
            saveTrip(trip)
        }
        
        saveMemoriesToFile()
    }
    
    public func deleteMemories(forTripId tripId: UUID) {
        memories.removeAll(where: { $0.tripId == tripId })
        saveMemoriesToFile()
    }
}
