//
//  Models.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var avatarURL: URL?
    var rating: Double
    var completedTasks: Int
    var isVerified: Bool
    var memberSince: Date
    var co2Saved: Double
    var vehicleDescription: String?
}

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var category: TaskCategory
    var status: TaskStatus
    var price: Int
    var images: [URL]
    var pickupLocation: Location
    var deliveryLocation: Location?
    var createdBy: User
    var acceptedBy: User?
    var createdAt: Date
    var completedAt: Date?
    var distance: Double // km fra bruker
}

enum TaskCategory: String, Codable, CaseIterable {
    case transport = "Transport"
    case moving = "Flyttehjelp"
    case recycling = "Gjenvinning"
    case pickup = "Henting"
    case other = "Annet"

    var icon: String {
        switch self {
        case .transport: return "car.fill"
        case .moving: return "shippingbox.fill"
        case .recycling: return "arrow.3.trianglepath"
        case .pickup: return "cart.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .transport: return "Frakt av ting"
        case .moving: return "Hjelp til å flytte"
        case .recycling: return "Kast & gjenvinning"
        case .pickup: return "Henting av varer"
        case .other: return "Alt mulig annet"
        }
    }
}

enum TaskStatus: String, Codable {
    case draft = "Utkast"
    case active = "Aktiv"
    case inProgress = "Pågår"
    case completed = "Fullført"
    case cancelled = "Kansellert"
}

struct Location: Codable {
    var address: String
    var latitude: Double
    var longitude: Double
    var city: String?
}

struct Message: Identifiable, Codable {
    let id: UUID
    let taskId: UUID
    let senderId: UUID
    let content: String
    let timestamp: Date
    var isRead: Bool
}

// MARK: - Ny Uber-aktig bestillingsmodell

enum OrderPhase: String, Codable {
    case idle               // Ingen aktiv bestilling
    case searching          // Leter etter en Kompis
    case matched            // Kompis funnet!
    case enRoute            // Kompis er på vei
    case arrived            // Kompis er fremme
    case inProgress         // Oppdraget pågår
    case completed          // Fullført!
    case rated              // Vurdert
}

struct ActiveOrder: Identifiable {
    let id: UUID
    let task: Task
    var phase: OrderPhase
    var assignedHelper: User?
    var estimatedArrival: Int? // minutter
    var startedAt: Date
    var messages: [ChatMessage]
}

struct ChatMessage: Identifiable {
    let id: UUID
    let senderId: UUID
    let senderName: String
    let content: String
    let timestamp: Date
}

struct FeedItem: Identifiable {
    let id: UUID
    let type: FeedItemType
    let task: Task
    let postedAgo: String
}

enum FeedItemType {
    case needsHelp      // "Trenger hjelp"
    case freeItem       // "Gis bort"
}

// MARK: - Biltype for bestilling

enum VehicleType: String, CaseIterable {
    case personbil = "Personbil"
    case varebil = "Varebil"
    case lastebil = "Lastebil"

    var icon: String {
        switch self {
        case .personbil: return "car.fill"
        case .varebil: return "truck.box.fill"
        case .lastebil: return "truck.pickup.side.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .personbil: return "Passer i bagasjen på en vanlig bil"
        case .varebil: return "Flere eller større ting som krever varebil"
        case .lastebil: return "Stort og tungt, trenger lastebil"
        }
    }
}
