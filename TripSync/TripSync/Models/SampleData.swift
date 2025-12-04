import Foundation
import UIKit
import CoreLocation

class SampleData {
    
    // MARK: - Singleton
    static let shared = SampleData()
    
    // MARK: - Properties
    
    private var users: [User] = []
    private var trips: [Trip] = []
    private var subgroups: [Subgroup] = []
    private var itineraryStops: [ItineraryStop] = []
    private var locations: [UserLocation] = []
    private var messages: [Message] = []
    private var invitations: [Invitation] = []
    private var memories: [Memory] = []
    
    var currentUser: User? {
        return users.first
    }
    
    private init() {
        loadAllData()
    }
    
    private func loadAllData() {
        loadUsers()
        loadTrips()
        loadSubgroups()
        loadItineraryStops()
        loadLocations()
        loadMessages()
        loadInvitations()
        loadMemories()
    }
    
    // MARK: - User Sample Data

    private func loadUsers() {
        let user1 = User(fullName: "Aditya Singh", email: "aditya.singh@example.com")
        let user2 = User(fullName: "Alice Johnson", email: "alice.johnson@example.com")
        let user3 = User(fullName: "Bob Smith", email: "bob.smith@example.com")
        let user4 = User(fullName: "John Doe", email: "john.doe@example.com")
        let user5 = User(fullName: "Ashley Kamin", email: "ashley.kamin@example.com")
        let user6 = User(fullName: "Amber Spiers", email: "amber.spiers@example.com")
        let user7 = User(fullName: "Gary Wilson", email: "gary.wilson@example.com")
        let user8 = User(fullName: "Fatima Hassan", email: "fatima.hassan@example.com")
        let user9 = User(fullName: "Simon Pickford", email: "simon.pickford@example.com")
        
        users = [user1, user2, user3, user4, user5, user6, user7, user8, user9]
    }
    
    // MARK: - Trip Sample Data

    private func loadTrips() {
        var allTrips: [Trip] = []
        
        // Current Trip
        var tokyo = Trip(
            name: "Tokyo Adventure 2025",
            location: "Tokyo, Japan",
            startDate: dateFromString("2025-10-29")!,
            endDate: dateFromString("2025-11-05")!,
            createdByUserId: users[0].id
        )
        tokyo.memberIds = [users[0].id, users[1].id, users[2].id, users[3].id]
        tokyo.status = .current
        tokyo.inviteCode = "TOKYO123"
        tokyo.coverImageURL = "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=1080"
        tokyo.coverImagePhotographerName = "Louie Martinez"
        allTrips.append(tokyo)
        
        // Upcoming Trips
        var mountain = Trip(
            name: "Autumn Mountain Retreat",
            location: "Mountains",
            startDate: dateFromString("2025-12-10")!,
            endDate: dateFromString("2025-12-15")!,
            createdByUserId: users[0].id
        )
        mountain.memberIds = [users[0].id, users[1].id, users[4].id, users[5].id]
        mountain.status = .upcoming
        mountain.coverImageURL = "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1080"
        mountain.coverImagePhotographerName = "Dmitry Bayer"
        allTrips.append(mountain)
        
        var island = Trip(
            name: "Tropical Island Getaway",
            location: "Island",
            startDate: dateFromString("2026-02-20")!,
            endDate: dateFromString("2026-02-27")!,
            createdByUserId: users[0].id
        )
        island.memberIds = [users[0].id, users[8].id]
        island.status = .upcoming
        island.coverImageURL = "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1080"
        island.coverImagePhotographerName = "Asad Photo Maldives"
        allTrips.append(island)
        
        // Past Trips
        var europe = Trip(
            name: "European City Explorer",
            location: "Europe",
            startDate: dateFromString("2023-08-20")!,
            endDate: dateFromString("2023-09-05")!,
            createdByUserId: users[0].id
        )
        europe.memberIds = [users[0].id, users[1].id]
        europe.status = .past
        europe.coverImageURL = "https://images.unsplash.com/photo-1467269204594-9661b134dd2b?w=1080"
        europe.coverImagePhotographerName = "Braden Collum"
        allTrips.append(europe)
        
        var coastal = Trip(
            name: "Coastal Road Trip Adventure",
            location: "Coast",
            startDate: dateFromString("2023-07-01")!,
            endDate: dateFromString("2023-07-07")!,
            createdByUserId: users[0].id
        )
        coastal.memberIds = [users[0].id, users[2].id, users[3].id]
        coastal.status = .past
        coastal.coverImageURL = "https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=1080"
        coastal.coverImagePhotographerName = "Luca Bravo"
        allTrips.append(coastal)
        
        var desert = Trip(
            name: "Desert Camping Expedition",
            location: "Desert",
            startDate: dateFromString("2023-04-12")!,
            endDate: dateFromString("2023-04-14")!,
            createdByUserId: users[0].id
        )
        desert.memberIds = [users[0].id, users[2].id, users[3].id, users[6].id, users[7].id]
        desert.status = .past
        desert.coverImageURL = "https://images.unsplash.com/photo-1473580044384-7ba9967e16a0?w=1080"
        desert.coverImagePhotographerName = "Yeshi Kangrang"
        allTrips.append(desert)
        
        trips = allTrips
    }

    // MARK: - Subgroup Sample Data
    
    private func loadSubgroups() {
        guard let tokyoTrip = trips.first(where: { $0.status == .current }) else { return }
        
        var allSubgroups: [Subgroup] = []
        
        let foodExplorers = Subgroup(
            name: "Food Explorers",
            description: "For those who want to try authentic Japanese cuisine",
            colorHex: "#FF8C42",
            tripId: tokyoTrip.id,
            memberIds: [users[1].id, users[2].id]
        )
        allSubgroups.append(foodExplorers)
        
        let mountainTrek = Subgroup(
            name: "Mountain Trek",
            description: "Come explore mountains of japan...",
            colorHex: "#007AFF",
            tripId: tokyoTrip.id,
            memberIds: [users[0].id, users[1].id, users[3].id]
        )
        allSubgroups.append(mountainTrek)
        
        subgroups = allSubgroups
    }

    // MARK: - Itinerary Stop Sample Data
    
    private func loadItineraryStops() {
        guard let tokyoTrip = trips.first(where: { $0.status == .current }),
              let foodExplorersSubgroup = subgroups.first,
              let mountainTrekSubgroup = subgroups.last else { return }
        
        var stops: [ItineraryStop] = []
        
        // Day 1 - October 29, 2025
        let sensojiTemple = ItineraryStop(
            title: "Sensoji Temple",
            location: "Sensoji Temple",
            address: "Asakusa, Tokyo",
            date: dateFromString("2025-10-29")!,
            time: timeFromString("14:40")!,
            tripId: tokyoTrip.id,
            subgroupId: nil,
            createdByUserId: users[0].id,
            category: "mappin.and.ellipse"
        )
        stops.append(sensojiTemple)
        
        let uenoRestaurant = ItineraryStop(
            title: "Ueno Restaurant",
            location: "Ueno Restaurant",
            address: "Odaiba, Tokyo",
            date: dateFromString("2025-10-29")!,
            time: timeFromString("16:00")!,
            tripId: tokyoTrip.id,
            subgroupId: foodExplorersSubgroup.id,
            createdByUserId: users[1].id,
            category: "fork.knife"
        )
        stops.append(uenoRestaurant)
        
        // Day 2 - October 30, 2025
        let mountTakao = ItineraryStop(
            title: "Mount Takao Trail",
            location: "Mount Takao",
            address: "Hachioji, Tokyo",
            date: dateFromString("2025-10-30")!,
            time: timeFromString("08:00")!,
            tripId: tokyoTrip.id,
            subgroupId: mountainTrekSubgroup.id,
            createdByUserId: users[3].id,
            category: "leaf.fill"
        )
        stops.append(mountTakao)
        
        let tokyoSkytree = ItineraryStop(
            title: "Tokyo Skytree",
            location: "Tokyo Skytree",
            address: "Sumida, Tokyo",
            date: dateFromString("2025-10-26")!,
            time: timeFromString("16:00")!,
            tripId: tokyoTrip.id,
            subgroupId: nil,
            createdByUserId: users[0].id,
            category: "mappin.and.ellipse"
        )
        stops.append(tokyoSkytree)
        
        let uenoPark = ItineraryStop(
            title: "Ueno Park",
            location: "Ueno Park",
            address: "Ueno, Tokyo",
            date: dateFromString("2025-10-26")!,
            time: timeFromString("18:15")!,
            tripId: tokyoTrip.id,
            subgroupId: nil,
            createdByUserId: users[0].id,
            category: "leaf.fill"
        )
        stops.append(uenoPark)
        
        let akihabara = ItineraryStop(
            title: "Akihabara Electric Town",
            location: "Akihabara",
            address: "Chiyoda, Tokyo",
            date: dateFromString("2025-10-26")!,
            time: timeFromString("20:00")!,
            tripId: tokyoTrip.id,
            subgroupId: nil,
            createdByUserId: users[2].id,
            category: "bag.fill"
        )
        stops.append(akihabara)
        
        let shinjukuGyoen = ItineraryStop(
            title: "Shinjuku Gyoen National Garden",
            location: "Shinjuku Gyoen",
            address: "Shinjuku, Tokyo",
            date: dateFromString("2025-10-26")!,
            time: timeFromString("10:30")!,
            tripId: tokyoTrip.id,
            subgroupId: nil,
            createdByUserId: users[1].id,
            category: "leaf.fill"
        )
        stops.append(shinjukuGyoen)
        
        itineraryStops = stops
    }

    // MARK: - Location Sample Data
    
    private func loadLocations() {
        guard let tokyoTrip = trips.first(where: { $0.status == .current }) else { return }
        
        var allLocations: [UserLocation] = []
        
        // Alice Johnson - Live (Warsaw, Poland - from map design)
        let aliceLocation = UserLocation(
            userId: users[1].id,
            tripId: tokyoTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 52.2319, longitude: 21.0122),
            isLive: true
        )
        allLocations.append(aliceLocation)
        
        // John Doe - Live
        let johnLocation = UserLocation(
            userId: users[3].id,
            tripId: tokyoTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122),
            isLive: true
        )
        allLocations.append(johnLocation)
        
        // Bob Smith - Offline
        let bobLocation = UserLocation(
            userId: users[2].id,
            tripId: tokyoTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 52.2250, longitude: 21.0100),
            isLive: false
        )
        allLocations.append(bobLocation)
        
        // Aditya Singh - Live
        let adityaLocation = UserLocation(
            userId: users[0].id,
            tripId: tokyoTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 52.2280, longitude: 21.0140),
            isLive: true
        )
        allLocations.append(adityaLocation)
        
        locations = allLocations
    }
    
    // MARK: - Message Sample Data

    private func loadMessages() {
        guard let tokyoTrip = trips.first(where: { $0.status == .current }),
              let foodExplorersSubgroup = subgroups.first,
              let mountainTrekSubgroup = subgroups.last else { return }
        
        var allMessages: [Message] = []
        
        // General chat messages
        let msg1 = Message(
            content: "Hey everyone! So excited for this trip!",
            senderUserId: users[1].id,
            tripId: tokyoTrip.id,
            subgroupId: nil
        )
        allMessages.append(msg1)
        
        let msg2 = Message(
            content: "Me too! Can't wait to explore Tokyo together.",
            senderUserId: users[2].id,
            tripId: tokyoTrip.id,
            subgroupId: nil
        )
        allMessages.append(msg2)
        
        let msg3 = Message(
            content: "I've made a list of must-visit temples!",
            senderUserId: users[3].id,
            tripId: tokyoTrip.id,
            subgroupId: nil
        )
        allMessages.append(msg3)
        
        // Food Explorers subgroup messages
        let msg4 = Message(
            content: "I found this amazing ramen place in Shibuya!",
            senderUserId: users[1].id,
            tripId: tokyoTrip.id,
            subgroupId: foodExplorersSubgroup.id
        )
        allMessages.append(msg4)
        
        let msg5 = Message(
            content: "Perfect! Let's add it to the itinerary.",
            senderUserId: users[2].id,
            tripId: tokyoTrip.id,
            subgroupId: foodExplorersSubgroup.id
        )
        allMessages.append(msg5)
        
        // Mountain Trek subgroup messages
        let msg6 = Message(
            content: "Mount Takao looks amazing! Who's joining?",
            senderUserId: users[3].id,
            tripId: tokyoTrip.id,
            subgroupId: mountainTrekSubgroup.id
        )
        allMessages.append(msg6)
        
        let msg7 = Message(
            content: "Count me in! I'll bring hiking gear.",
            senderUserId: users[0].id,
            tripId: tokyoTrip.id,
            subgroupId: mountainTrekSubgroup.id
        )
        allMessages.append(msg7)
        
        // Announcement
        var announcement = Message(
            content: "Meeting at hotel lobby at 9 AM tomorrow!",
            senderUserId: users[0].id,
            tripId: tokyoTrip.id,
            subgroupId: nil,
            isAnnouncement: true
        )
        announcement.announcementTitle = "Tomorrow's Plan"
        announcement.sendNotification = true
        allMessages.append(announcement)
        
        messages = allMessages
    }

    // MARK: - Invitation Sample Data
    
    private func loadInvitations() {
        guard let tokyoTrip = trips.first(where: { $0.status == .current }),
              let foodExplorersSubgroup = subgroups.first else { return }
        
        var allInvitations: [Invitation] = []
        
        // Pending trip invitation
        let tripInvite = Invitation(
            type: .trip,
            tripId: tokyoTrip.id,
            subgroupId: nil,
            invitedByUserId: users[0].id,
            invitedUserId: users[4].id
        )
        allInvitations.append(tripInvite)
        
        // Pending subgroup invitation
        let subgroupInvite = Invitation(
            type: .subgroup,
            tripId: tokyoTrip.id,
            subgroupId: foodExplorersSubgroup.id,
            invitedByUserId: users[0].id,
            invitedUserId: users[3].id
        )
        allInvitations.append(subgroupInvite)
        
        invitations = allInvitations
    }

    // MARK: - Memory Sample Data
    
    private func loadMemories() {
        var allMemories: [Memory] = []
        
        // Past trips memories
        if let europeTrip = trips.first(where: { $0.name == "European City Explorer" }) {
            let memory1 = Memory(
                tripId: europeTrip.id,
                photoData: [],
                notes: "Amazing architecture in Prague and Vienna"
            )
            allMemories.append(memory1)
        }
        
        if let coastalTrip = trips.first(where: { $0.name == "Coastal Road Trip Adventure" }) {
            let memory2 = Memory(
                tripId: coastalTrip.id,
                photoData: [],
                notes: "Beautiful sunsets along the Pacific Coast Highway"
            )
            allMemories.append(memory2)
        }
        
        if let desertTrip = trips.first(where: { $0.name == "Desert Camping Expedition" }) {
            let memory3 = Memory(
                tripId: desertTrip.id,
                photoData: [],
                notes: "Stargazing under the clear desert sky was unforgettable"
            )
            allMemories.append(memory3)
        }
        
        memories = allMemories
    }
    
    // MARK: - Utility Methods
    
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    private func timeFromString(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: timeString)
    }
}

// MARK: - Sample Data Population

extension SampleData {
    
    /// Populate DataModel with sample data
    func populateDataModel() {
        let dataModel = DataModel.shared
        
        // Set current user
        dataModel.setCurrentUser(currentUser)
        
        // Save all users
        users.forEach { dataModel.saveUser($0) }
        
        // Save all trips
        trips.forEach { dataModel.saveTrip($0) }
        
        // Save all subgroups
        subgroups.forEach { dataModel.saveSubgroup($0) }
        
        // Save all itinerary stops
        itineraryStops.forEach { dataModel.saveItineraryStop($0) }
        
        // Save all messages
        messages.forEach { dataModel.saveMessage($0) }
        
        // Save all locations
        locations.forEach { dataModel.saveLocation($0) }
        
        // Save all invitations
        invitations.forEach { dataModel.saveInvitation($0) }
        
        // Save all memories
        memories.forEach { dataModel.saveMemory($0) }
    }
}
