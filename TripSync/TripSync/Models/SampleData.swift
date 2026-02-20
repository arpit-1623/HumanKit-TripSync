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
    }
    
    // MARK: - User Sample Data

    private func loadUsers() {
        // Using a default password hash for demo users (password: "demo123")
        let demoPasswordHash = "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f"
        
        let user1 = User(fullName: "Arpit Garg", email: "arpit.garg@example.com", passwordHash: demoPasswordHash)
        let user2 = User(fullName: "Priya Sharma", email: "priya.sharma@example.com", passwordHash: demoPasswordHash)
        let user3 = User(fullName: "Rahul Mehta", email: "rahul.mehta@example.com", passwordHash: demoPasswordHash)
        let user4 = User(fullName: "Ananya Reddy", email: "ananya.reddy@example.com", passwordHash: demoPasswordHash)
        let user5 = User(fullName: "Karan Singh", email: "karan.singh@example.com", passwordHash: demoPasswordHash)
        let user6 = User(fullName: "Neha Kapoor", email: "neha.kapoor@example.com", passwordHash: demoPasswordHash)
        let user7 = User(fullName: "Vikram Patel", email: "vikram.patel@example.com", passwordHash: demoPasswordHash)
        let user8 = User(fullName: "Ishita Joshi", email: "ishita.joshi@example.com", passwordHash: demoPasswordHash)
        let user9 = User(fullName: "Dev Malhotra", email: "dev.malhotra@example.com", passwordHash: demoPasswordHash)
        
        users = [user1, user2, user3, user4, user5, user6, user7, user8, user9]
    }
    
    // MARK: - Trip Sample Data

    private func loadTrips() {
        var allTrips: [Trip] = []
        
        // ──────────── CURRENT TRIP ────────────
        var goa = Trip(
            name: "Goa Beach Vibes 🏖️",
            location: "Goa, India",
            startDate: dateFromString("2026-02-15")!,
            endDate: dateFromString("2026-02-28")!,
            createdByUserId: users[0].id
        )
        goa.memberIds = [users[0].id, users[1].id, users[2].id, users[3].id, users[4].id, users[5].id]
        goa.status = .current
        goa.inviteCode = "GOA2026X"
        goa.coverImageURL = "https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=1080"
        goa.coverImagePhotographerName = "Siddharth Kothari"
        allTrips.append(goa)
        
        // ──────────── UPCOMING TRIPS ────────────
        var manali = Trip(
            name: "Manali Snow Trek ❄️",
            location: "Manali, Himachal Pradesh",
            startDate: dateFromString("2026-03-15")!,
            endDate: dateFromString("2026-03-22")!,
            createdByUserId: users[0].id
        )
        manali.memberIds = [users[0].id, users[2].id, users[4].id, users[6].id]
        manali.status = .upcoming
        manali.inviteCode = "MNLI2026"
        manali.coverImageURL = "https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=1080"
        manali.coverImagePhotographerName = "Abhinav Mathur"
        allTrips.append(manali)
        
        var bali = Trip(
            name: "Bali Cultural Escape 🌴",
            location: "Bali, Indonesia",
            startDate: dateFromString("2026-06-10")!,
            endDate: dateFromString("2026-06-20")!,
            createdByUserId: users[1].id
        )
        bali.memberIds = [users[0].id, users[1].id, users[3].id, users[7].id, users[8].id]
        bali.status = .upcoming
        bali.inviteCode = "BALI2026"
        bali.coverImageURL = "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=1080"
        bali.coverImagePhotographerName = "Alfiano Sutianto"
        allTrips.append(bali)
        
        // ──────────── PAST TRIPS ────────────
        var rajasthan = Trip(
            name: "Royal Rajasthan Road Trip",
            location: "Rajasthan, India",
            startDate: dateFromString("2025-12-20")!,
            endDate: dateFromString("2025-12-28")!,
            createdByUserId: users[0].id
        )
        rajasthan.memberIds = [users[0].id, users[1].id, users[2].id, users[3].id]
        rajasthan.status = .past
        rajasthan.inviteCode = "RJST2025"
        rajasthan.coverImageURL = "https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=1080"
        rajasthan.coverImagePhotographerName = "Annie Spratt"
        allTrips.append(rajasthan)
        
        var kerala = Trip(
            name: "Kerala Backwaters Cruise",
            location: "Kerala, India",
            startDate: dateFromString("2025-10-05")!,
            endDate: dateFromString("2025-10-12")!,
            createdByUserId: users[2].id
        )
        kerala.memberIds = [users[0].id, users[2].id, users[5].id, users[6].id, users[7].id]
        kerala.status = .past
        kerala.inviteCode = "KRLA2025"
        kerala.coverImageURL = "https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=1080"
        kerala.coverImagePhotographerName = "Pawan Kumar"
        allTrips.append(kerala)
        
        var tokyo = Trip(
            name: "Tokyo Tech & Culture",
            location: "Tokyo, Japan",
            startDate: dateFromString("2025-07-01")!,
            endDate: dateFromString("2025-07-10")!,
            createdByUserId: users[0].id
        )
        tokyo.memberIds = [users[0].id, users[1].id, users[4].id]
        tokyo.status = .past
        tokyo.inviteCode = "TOKY2025"
        tokyo.coverImageURL = "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=1080"
        tokyo.coverImagePhotographerName = "Louie Martinez"
        allTrips.append(tokyo)
        
        var ladakh = Trip(
            name: "Ladakh Bike Expedition 🏍️",
            location: "Ladakh, India",
            startDate: dateFromString("2025-05-15")!,
            endDate: dateFromString("2025-05-25")!,
            createdByUserId: users[4].id
        )
        ladakh.memberIds = [users[0].id, users[2].id, users[4].id, users[6].id, users[8].id]
        ladakh.status = .past
        ladakh.inviteCode = "LDKH2025"
        ladakh.coverImageURL = "https://images.unsplash.com/photo-1626015365107-63de8890fbb4?w=1080"
        ladakh.coverImagePhotographerName = "Rohit Singh"
        allTrips.append(ladakh)
        
        trips = allTrips
    }

    // MARK: - Subgroup Sample Data
    
    private func loadSubgroups() {
        guard let goaTrip = trips.first(where: { $0.name.contains("Goa") }),
              let manaliTrip = trips.first(where: { $0.name.contains("Manali") }) else { return }
        
        var allSubgroups: [Subgroup] = []
        
        // Goa subgroups
        let beachParty = Subgroup(
            name: "Beach Party Crew",
            description: "Sunset parties, beach shacks, and nightlife lovers",
            colorHex: "#FF6B6B",
            tripId: goaTrip.id,
            memberIds: [users[0].id, users[1].id, users[4].id],
            createdByUserId: users[0].id
        )
        allSubgroups.append(beachParty)
        
        let foodCrawl = Subgroup(
            name: "Seafood Crawl",
            description: "Exploring the best seafood and local Goan cuisine",
            colorHex: "#FF8C42",
            tripId: goaTrip.id,
            memberIds: [users[1].id, users[2].id, users[3].id],
            createdByUserId: users[1].id
        )
        allSubgroups.append(foodCrawl)
        
        let waterSports = Subgroup(
            name: "Water Sports Squad",
            description: "Jet skiing, parasailing, banana boat rides",
            colorHex: "#4ECDC4",
            tripId: goaTrip.id,
            memberIds: [users[0].id, users[2].id, users[4].id, users[5].id],
            createdByUserId: users[2].id
        )
        allSubgroups.append(waterSports)
        
        let heritage = Subgroup(
            name: "Heritage Walkers",
            description: "Old Goa churches, forts, and Portuguese architecture",
            colorHex: "#9B59B6",
            tripId: goaTrip.id,
            memberIds: [users[3].id, users[5].id],
            createdByUserId: users[3].id
        )
        allSubgroups.append(heritage)
        
        // Manali subgroup
        let trekkingGroup = Subgroup(
            name: "High Altitude Trekkers",
            description: "Serious hikers going for Hampta Pass",
            colorHex: "#2ECC71",
            tripId: manaliTrip.id,
            memberIds: [users[0].id, users[4].id, users[6].id],
            createdByUserId: users[0].id
        )
        allSubgroups.append(trekkingGroup)
        
        subgroups = allSubgroups
    }

    // MARK: - Itinerary Stop Sample Data
    
    private func loadItineraryStops() {
        guard let goaTrip = trips.first(where: { $0.name.contains("Goa") }),
              let manaliTrip = trips.first(where: { $0.name.contains("Manali") }) else { return }
        
        let beachParty = subgroups.first(where: { $0.name == "Beach Party Crew" })
        let foodCrawl = subgroups.first(where: { $0.name == "Seafood Crawl" })
        let waterSports = subgroups.first(where: { $0.name == "Water Sports Squad" })
        let heritage = subgroups.first(where: { $0.name == "Heritage Walkers" })
        let trekking = subgroups.first(where: { $0.name == "High Altitude Trekkers" })
        
        var stops: [ItineraryStop] = []
        
        // ── GOA: Day 1 – Feb 15 ──
        stops.append(ItineraryStop(
            title: "Arrive at Dabolim Airport",
            location: "Goa International Airport",
            address: "Dabolim, Goa",
            date: dateFromString("2026-02-15")!,
            time: timeFromString("11:00")!,
            tripId: goaTrip.id,
            subgroupId: nil,
            createdByUserId: users[0].id,
            category: "airplane.arrival"
        ))
        
        stops.append(ItineraryStop(
            title: "Check-in at Resort",
            location: "Taj Holiday Village",
            address: "Calangute, North Goa",
            date: dateFromString("2026-02-15")!,
            time: timeFromString("14:00")!,
            tripId: goaTrip.id,
            subgroupId: nil,
            createdByUserId: users[0].id,
            category: "bed.double.fill"
        ))
        
        stops.append(ItineraryStop(
            title: "Sunset at Baga Beach",
            location: "Baga Beach",
            address: "Baga, North Goa",
            date: dateFromString("2026-02-15")!,
            time: timeFromString("17:30")!,
            tripId: goaTrip.id,
            subgroupId: beachParty?.id,
            createdByUserId: users[1].id,
            category: "sun.max.fill"
        ))
        
        // ── GOA: Day 2 – Feb 16 ──
        stops.append(ItineraryStop(
            title: "Parasailing at Calangute",
            location: "Calangute Beach",
            address: "Calangute, North Goa",
            date: dateFromString("2026-02-16")!,
            time: timeFromString("09:00")!,
            tripId: goaTrip.id,
            subgroupId: waterSports?.id,
            createdByUserId: users[2].id,
            category: "wind"
        ))
        
        stops.append(ItineraryStop(
            title: "Lunch at Fisherman's Wharf",
            location: "Fisherman's Wharf",
            address: "Cavelossim, South Goa",
            date: dateFromString("2026-02-16")!,
            time: timeFromString("13:00")!,
            tripId: goaTrip.id,
            subgroupId: foodCrawl?.id,
            createdByUserId: users[1].id,
            category: "fork.knife"
        ))
        
        stops.append(ItineraryStop(
            title: "Visit Basilica of Bom Jesus",
            location: "Basilica of Bom Jesus",
            address: "Old Goa",
            date: dateFromString("2026-02-16")!,
            time: timeFromString("15:30")!,
            tripId: goaTrip.id,
            subgroupId: heritage?.id,
            createdByUserId: users[3].id,
            category: "building.columns.fill"
        ))
        
        // ── GOA: Day 3 – Feb 17 ──
        stops.append(ItineraryStop(
            title: "Dudhsagar Waterfall Trip",
            location: "Dudhsagar Falls",
            address: "Sanguem, Goa",
            date: dateFromString("2026-02-17")!,
            time: timeFromString("07:00")!,
            tripId: goaTrip.id,
            subgroupId: nil,
            createdByUserId: users[0].id,
            category: "drop.fill"
        ))
        
        stops.append(ItineraryStop(
            title: "Spice Plantation Tour",
            location: "Sahakari Spice Farm",
            address: "Ponda, Goa",
            date: dateFromString("2026-02-17")!,
            time: timeFromString("14:00")!,
            tripId: goaTrip.id,
            subgroupId: nil,
            createdByUserId: users[3].id,
            category: "leaf.fill"
        ))
        
        // ── GOA: Day 4 – Feb 18 ──
        stops.append(ItineraryStop(
            title: "Jet Skiing at Mobor Beach",
            location: "Mobor Beach",
            address: "Cavelossim, South Goa",
            date: dateFromString("2026-02-18")!,
            time: timeFromString("10:00")!,
            tripId: goaTrip.id,
            subgroupId: waterSports?.id,
            createdByUserId: users[4].id,
            category: "figure.water.fitness"
        ))
        
        stops.append(ItineraryStop(
            title: "Beach BBQ Dinner",
            location: "Tito's Lane",
            address: "Baga, North Goa",
            date: dateFromString("2026-02-18")!,
            time: timeFromString("19:30")!,
            tripId: goaTrip.id,
            subgroupId: beachParty?.id,
            createdByUserId: users[0].id,
            category: "flame.fill"
        ))
        
        // ── GOA: Day 5 – Feb 19 ──
        stops.append(ItineraryStop(
            title: "Morning Yoga on the Beach",
            location: "Ashwem Beach",
            address: "Ashwem, North Goa",
            date: dateFromString("2026-02-19")!,
            time: timeFromString("06:30")!,
            tripId: goaTrip.id,
            subgroupId: nil,
            createdByUserId: users[5].id,
            category: "figure.mind.and.body"
        ))
        
        stops.append(ItineraryStop(
            title: "Flea Market Shopping",
            location: "Saturday Night Market",
            address: "Arpora, North Goa",
            date: dateFromString("2026-02-19")!,
            time: timeFromString("18:00")!,
            tripId: goaTrip.id,
            subgroupId: nil,
            createdByUserId: users[1].id,
            category: "bag.fill"
        ))
        
        // ── GOA: Day 6 – Feb 20 ──
        stops.append(ItineraryStop(
            title: "Scuba Diving at Grande Island",
            location: "Grande Island",
            address: "Off Vasco da Gama, Goa",
            date: dateFromString("2026-02-20")!,
            time: timeFromString("08:30")!,
            tripId: goaTrip.id,
            subgroupId: waterSports?.id,
            createdByUserId: users[2].id,
            category: "water.waves"
        ))
        
        stops.append(ItineraryStop(
            title: "Dinner at Antares",
            location: "Antares Restaurant",
            address: "Vagator, North Goa",
            date: dateFromString("2026-02-20")!,
            time: timeFromString("20:00")!,
            tripId: goaTrip.id,
            subgroupId: foodCrawl?.id,
            createdByUserId: users[3].id,
            category: "fork.knife"
        ))
        
        // ── GOA: Day 8 – Feb 22 ──
        stops.append(ItineraryStop(
            title: "Dolphin Watching Boat Trip",
            location: "Sinquerim Jetty",
            address: "Sinquerim, North Goa",
            date: dateFromString("2026-02-22")!,
            time: timeFromString("07:00")!,
            tripId: goaTrip.id,
            subgroupId: nil,
            createdByUserId: users[4].id,
            category: "binoculars.fill"
        ))
        
        // ── GOA: Day 10 – Feb 24 ──
        stops.append(ItineraryStop(
            title: "Aguada Fort Visit",
            location: "Fort Aguada",
            address: "Sinquerim, North Goa",
            date: dateFromString("2026-02-24")!,
            time: timeFromString("09:00")!,
            tripId: goaTrip.id,
            subgroupId: heritage?.id,
            createdByUserId: users[5].id,
            category: "building.columns.fill"
        ))
        
        // ── GOA: Last Day – Feb 28 ──
        stops.append(ItineraryStop(
            title: "Farewell Brunch",
            location: "Cafe Mambo",
            address: "Baga, North Goa",
            date: dateFromString("2026-02-28")!,
            time: timeFromString("10:00")!,
            tripId: goaTrip.id,
            subgroupId: nil,
            createdByUserId: users[0].id,
            category: "cup.and.saucer.fill"
        ))
        
        stops.append(ItineraryStop(
            title: "Depart from Airport",
            location: "Goa International Airport",
            address: "Dabolim, Goa",
            date: dateFromString("2026-02-28")!,
            time: timeFromString("16:00")!,
            tripId: goaTrip.id,
            subgroupId: nil,
            createdByUserId: users[0].id,
            category: "airplane.departure"
        ))
        
        // ── MANALI STOPS ──
        stops.append(ItineraryStop(
            title: "Arrive in Manali",
            location: "Manali Bus Stand",
            address: "Mall Road, Manali",
            date: dateFromString("2026-03-15")!,
            time: timeFromString("10:00")!,
            tripId: manaliTrip.id,
            subgroupId: nil,
            createdByUserId: users[0].id,
            category: "bus.fill"
        ))
        
        stops.append(ItineraryStop(
            title: "Hampta Pass Trek Start",
            location: "Jobra Campsite",
            address: "Hampta Valley, Manali",
            date: dateFromString("2026-03-16")!,
            time: timeFromString("06:00")!,
            tripId: manaliTrip.id,
            subgroupId: trekking?.id,
            createdByUserId: users[4].id,
            category: "figure.hiking"
        ))
        
        stops.append(ItineraryStop(
            title: "Solang Valley Snow Sports",
            location: "Solang Valley",
            address: "Solang Nullah, Manali",
            date: dateFromString("2026-03-18")!,
            time: timeFromString("09:00")!,
            tripId: manaliTrip.id,
            subgroupId: nil,
            createdByUserId: users[2].id,
            category: "snowflake"
        ))
        
        stops.append(ItineraryStop(
            title: "Visit Hadimba Temple",
            location: "Hidimba Devi Temple",
            address: "Old Manali",
            date: dateFromString("2026-03-19")!,
            time: timeFromString("11:00")!,
            tripId: manaliTrip.id,
            subgroupId: nil,
            createdByUserId: users[6].id,
            category: "building.columns.fill"
        ))
        
        // Link stops to trips
        for i in 0..<stops.count {
            let tripId = stops[i].tripId
            if var trip = trips.first(where: { $0.id == tripId }),
               let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
                trip.itineraryStopIds.append(stops[i].id)
                trips[tripIndex] = trip
            }
        }
        
        // Link subgroups to trips
        for sg in subgroups {
            if var trip = trips.first(where: { $0.id == sg.tripId }),
               let tripIndex = trips.firstIndex(where: { $0.id == sg.tripId }) {
                if !trip.subgroupIds.contains(sg.id) {
                    trip.subgroupIds.append(sg.id)
                    trips[tripIndex] = trip
                }
            }
        }
        
        itineraryStops = stops
    }

    // MARK: - Location Sample Data
    
    private func loadLocations() {
        guard let goaTrip = trips.first(where: { $0.name.contains("Goa") }) else { return }
        
        var allLocations: [UserLocation] = []
        
        // Arpit — Live at Baga Beach
        allLocations.append(UserLocation(
            userId: users[0].id,
            tripId: goaTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 15.5554, longitude: 73.7514),
            isLive: true
        ))
        
        // Priya — Live near Calangute
        allLocations.append(UserLocation(
            userId: users[1].id,
            tripId: goaTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 15.5438, longitude: 73.7554),
            isLive: true
        ))
        
        // Rahul — Live at Anjuna Beach
        allLocations.append(UserLocation(
            userId: users[2].id,
            tripId: goaTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 15.5729, longitude: 73.7410),
            isLive: true
        ))
        
        // Ananya — Offline, last seen near Panjim
        allLocations.append(UserLocation(
            userId: users[3].id,
            tripId: goaTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 15.4989, longitude: 73.8278),
            isLive: false
        ))
        
        // Karan — Live near Vagator
        allLocations.append(UserLocation(
            userId: users[4].id,
            tripId: goaTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 15.5965, longitude: 73.7389),
            isLive: true
        ))
        
        // Neha — Offline, last seen at Palolem
        allLocations.append(UserLocation(
            userId: users[5].id,
            tripId: goaTrip.id,
            coordinate: CLLocationCoordinate2D(latitude: 15.0100, longitude: 74.0232),
            isLive: false
        ))
        
        locations = allLocations
    }
    
    // MARK: - Message Sample Data

    private func loadMessages() {
        guard let goaTrip = trips.first(where: { $0.name.contains("Goa") }),
              let manaliTrip = trips.first(where: { $0.name.contains("Manali") }) else { return }
        
        let beachParty = subgroups.first(where: { $0.name == "Beach Party Crew" })
        let foodCrawl = subgroups.first(where: { $0.name == "Seafood Crawl" })
        let waterSports = subgroups.first(where: { $0.name == "Water Sports Squad" })
        
        var allMessages: [Message] = []
        
        // ── GOA: General Chat ──
        allMessages.append(Message(
            content: "Finally here! The weather is gorgeous 🌊",
            senderUserId: users[0].id,
            tripId: goaTrip.id,
            subgroupId: nil
        ))
        
        allMessages.append(Message(
            content: "Just checked in! Room has an ocean view 😍",
            senderUserId: users[1].id,
            tripId: goaTrip.id,
            subgroupId: nil
        ))
        
        allMessages.append(Message(
            content: "Anyone up for a quick swim before dinner?",
            senderUserId: users[2].id,
            tripId: goaTrip.id,
            subgroupId: nil
        ))
        
        allMessages.append(Message(
            content: "I'm in! Meet at the pool in 20?",
            senderUserId: users[4].id,
            tripId: goaTrip.id,
            subgroupId: nil
        ))
        
        allMessages.append(Message(
            content: "Don't forget sunscreen guys, it's intense out there ☀️",
            senderUserId: users[5].id,
            tripId: goaTrip.id,
            subgroupId: nil
        ))
        
        allMessages.append(Message(
            content: "Has anyone tried the coconut water from the stand near the gate?",
            senderUserId: users[3].id,
            tripId: goaTrip.id,
            subgroupId: nil
        ))
        
        allMessages.append(Message(
            content: "Yes! It's the best. Get the one with malai 🥥",
            senderUserId: users[1].id,
            tripId: goaTrip.id,
            subgroupId: nil
        ))
        
        // ── GOA: Beach Party Crew messages ──
        allMessages.append(Message(
            content: "Tito's tonight? I heard there's a DJ set 🎧",
            senderUserId: users[0].id,
            tripId: goaTrip.id,
            subgroupId: beachParty?.id
        ))
        
        allMessages.append(Message(
            content: "Let's gooo! Pre-game at the shack first?",
            senderUserId: users[4].id,
            tripId: goaTrip.id,
            subgroupId: beachParty?.id
        ))
        
        allMessages.append(Message(
            content: "I'll bring the speakers for the pre-game 🔊",
            senderUserId: users[1].id,
            tripId: goaTrip.id,
            subgroupId: beachParty?.id
        ))
        
        // ── GOA: Seafood Crawl messages ──
        allMessages.append(Message(
            content: "Found the BEST prawn thali at Martin's Corner!",
            senderUserId: users[1].id,
            tripId: goaTrip.id,
            subgroupId: foodCrawl?.id
        ))
        
        allMessages.append(Message(
            content: "Adding it to our list. We need to try Ritz Classic too",
            senderUserId: users[2].id,
            tripId: goaTrip.id,
            subgroupId: foodCrawl?.id
        ))
        
        allMessages.append(Message(
            content: "I want to try that Goan fish curry place everyone talks about",
            senderUserId: users[3].id,
            tripId: goaTrip.id,
            subgroupId: foodCrawl?.id
        ))
        
        // ── GOA: Water Sports Squad messages ──
        allMessages.append(Message(
            content: "Booked parasailing for tomorrow at 9 AM! ₹800 per person",
            senderUserId: users[2].id,
            tripId: goaTrip.id,
            subgroupId: waterSports?.id
        ))
        
        allMessages.append(Message(
            content: "Can we do banana boat ride after? 🍌",
            senderUserId: users[5].id,
            tripId: goaTrip.id,
            subgroupId: waterSports?.id
        ))
        
        allMessages.append(Message(
            content: "I'm a bit scared of parasailing tbh 😅",
            senderUserId: users[0].id,
            tripId: goaTrip.id,
            subgroupId: waterSports?.id
        ))
        
        allMessages.append(Message(
            content: "It's super safe, you'll love it!",
            senderUserId: users[4].id,
            tripId: goaTrip.id,
            subgroupId: waterSports?.id
        ))
        
        // ── GOA: Announcements ──
        var announcement1 = Message(
            content: "Group dinner at Fisherman's Wharf tomorrow at 8 PM. Everyone please be there by 7:45. I've reserved a table for 6.",
            senderUserId: users[0].id,
            tripId: goaTrip.id,
            subgroupId: nil,
            isAnnouncement: true,
            priority: .important
        )
        announcement1.announcementTitle = "Group Dinner Tomorrow"
        announcement1.sendNotification = true
        allMessages.append(announcement1)
        
        var announcement2 = Message(
            content: "⚠️ Beach advisory: Strong currents reported at Calangute today. Please avoid swimming beyond the flags. Lifeguards will be limited after 5 PM.",
            senderUserId: users[0].id,
            tripId: goaTrip.id,
            subgroupId: nil,
            isAnnouncement: true,
            priority: .veryImportant
        )
        announcement2.announcementTitle = "Beach Safety Alert"
        announcement2.sendNotification = true
        allMessages.append(announcement2)
        
        var announcement3 = Message(
            content: "FYI — The Dudhsagar waterfall trip has been moved from Feb 17 to Feb 18 due to vehicle availability. Same time (7 AM pickup).",
            senderUserId: users[0].id,
            tripId: goaTrip.id,
            subgroupId: nil,
            isAnnouncement: true,
            priority: .general
        )
        announcement3.announcementTitle = "Dudhsagar Trip Rescheduled"
        announcement3.sendNotification = false
        allMessages.append(announcement3)
        
        // ── MANALI: General chat ──
        allMessages.append(Message(
            content: "Can't wait for Manali! Anyone bringing snow gear?",
            senderUserId: users[0].id,
            tripId: manaliTrip.id,
            subgroupId: nil
        ))
        
        allMessages.append(Message(
            content: "I have extra gloves and jackets if anyone needs",
            senderUserId: users[4].id,
            tripId: manaliTrip.id,
            subgroupId: nil
        ))
        
        allMessages.append(Message(
            content: "Should we rent snow boots locally or bring our own?",
            senderUserId: users[6].id,
            tripId: manaliTrip.id,
            subgroupId: nil
        ))
        
        messages = allMessages
    }

    // MARK: - Invitation Sample Data
    
    private func loadInvitations() {
        guard let goaTrip = trips.first(where: { $0.name.contains("Goa") }),
              let baliTrip = trips.first(where: { $0.name.contains("Bali") }) else { return }
        
        var allInvitations: [Invitation] = []
        
        // Pending trip invitation: Vikram invited to Goa trip
        allInvitations.append(Invitation(
            type: .trip,
            tripId: goaTrip.id,
            subgroupId: nil,
            invitedByUserId: users[0].id,
            invitedUserId: users[6].id
        ))
        
        // Pending trip invitation: Ishita invited to Goa trip
        allInvitations.append(Invitation(
            type: .trip,
            tripId: goaTrip.id,
            subgroupId: nil,
            invitedByUserId: users[0].id,
            invitedUserId: users[7].id
        ))
        
        // Subgroup invitation: Arpit invited to Seafood Crawl by Priya
        if let foodCrawl = subgroups.first(where: { $0.name == "Seafood Crawl" }) {
            allInvitations.append(Invitation(
                type: .subgroup,
                tripId: goaTrip.id,
                subgroupId: foodCrawl.id,
                invitedByUserId: users[1].id,
                invitedUserId: users[0].id
            ))
        }
        
        // Subgroup invitation: Arpit invited to Heritage Walkers by Ananya
        if let heritage = subgroups.first(where: { $0.name == "Heritage Walkers" }) {
            allInvitations.append(Invitation(
                type: .subgroup,
                tripId: goaTrip.id,
                subgroupId: heritage.id,
                invitedByUserId: users[3].id,
                invitedUserId: users[0].id
            ))
        }
        
        // Pending trip invitation: Dev invited to Bali trip
        allInvitations.append(Invitation(
            type: .trip,
            tripId: baliTrip.id,
            subgroupId: nil,
            invitedByUserId: users[1].id,
            invitedUserId: users[6].id
        ))
        
        invitations = allInvitations
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
    
    /// Clears all existing data and populates DataModel with comprehensive sample data
    func populateDataModel() {
        let dataModel = DataModel.shared
        
        // Clear all existing data first
        dataModel.clearAllData()
        
        // Reload sample data (since singleton keeps stale refs)
        loadAllData()
        
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

    }
}
