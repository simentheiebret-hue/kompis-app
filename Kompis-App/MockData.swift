//
//  MockData.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import Foundation

struct MockData {

    static let currentUser = User(
        id: UUID(),
        name: "Simen",
        email: "simen@example.com",
        phone: "+47 912 34 567",
        avatarURL: nil,
        rating: 4.9,
        completedTasks: 12,
        isVerified: true,
        memberSince: Date().addingTimeInterval(-86400 * 180),
        co2Saved: 127,
        vehicleDescription: nil
    )

    static let users = [
        User(id: UUID(), name: "Ola Nordmann", email: "ola@example.com", phone: nil, avatarURL: nil, rating: 4.8, completedTasks: 23, isVerified: true, memberSince: Date().addingTimeInterval(-86400 * 365), co2Saved: 89, vehicleDescription: "VW Transporter"),
        User(id: UUID(), name: "Kari Hansen", email: "kari@example.com", phone: nil, avatarURL: nil, rating: 4.9, completedTasks: 45, isVerified: true, memberSince: Date().addingTimeInterval(-86400 * 400), co2Saved: 234, vehicleDescription: "Volvo V60"),
        User(id: UUID(), name: "Per Johansen", email: "per@example.com", phone: nil, avatarURL: nil, rating: 4.6, completedTasks: 8, isVerified: false, memberSince: Date().addingTimeInterval(-86400 * 60), co2Saved: 34, vehicleDescription: nil),
    ]

    static let tasks = [
        Task(
            id: UUID(),
            title: "Hente sofa fra Finn",
            description: "3-seter sofa fra Finn.no. Står i 2. etasje uten heis. Ca 40 kg, trenger to personer for å bære.",
            category: .transport,
            status: .active,
            price: 350,
            images: [],
            pickupLocation: Location(address: "Thorvald Meyers gate 15, Oslo", latitude: 59.9226, longitude: 10.7594, city: "Oslo"),
            deliveryLocation: Location(address: "Bygdøy allé 23, Oslo", latitude: 59.9139, longitude: 10.7018, city: "Oslo"),
            createdBy: users[0],
            acceptedBy: nil,
            createdAt: Date(),
            completedAt: nil,
            distance: 2.3
        ),
        Task(
            id: UUID(),
            title: "Kartonger til gjenvinning",
            description: "Ca 10 kartonger og 2 poser med glass. Må kjøres til gjenvinningsstasjon.",
            category: .recycling,
            status: .active,
            price: 280,
            images: [],
            pickupLocation: Location(address: "Frognerveien 42, Oslo", latitude: 59.9193, longitude: 10.7018, city: "Oslo"),
            deliveryLocation: nil,
            createdBy: users[1],
            acceptedBy: nil,
            createdAt: Date().addingTimeInterval(-3600),
            completedAt: nil,
            distance: 4.1
        ),
        Task(
            id: UUID(),
            title: "IKEA-henting fra Furuset",
            description: "Bestilt MALM kommode og BILLY bokhylle. Flatpakket.",
            category: .pickup,
            status: .active,
            price: 280,
            images: [],
            pickupLocation: Location(address: "IKEA Furuset", latitude: 59.9428, longitude: 10.8774, city: "Oslo"),
            deliveryLocation: Location(address: "Torshov, Oslo", latitude: 59.9346, longitude: 10.7663, city: "Oslo"),
            createdBy: users[2],
            acceptedBy: nil,
            createdAt: Date().addingTimeInterval(-7200),
            completedAt: nil,
            distance: 8.1
        ),
        Task(
            id: UUID(),
            title: "Flytte 3 esker med bøker",
            description: "Tre tunge esker med bøker som må flyttes fra kjeller til 4. etasje. Heis finnes.",
            category: .moving,
            status: .active,
            price: 200,
            images: [],
            pickupLocation: Location(address: "Sagene, Oslo", latitude: 59.9411, longitude: 10.7539, city: "Oslo"),
            deliveryLocation: nil,
            createdBy: users[0],
            acceptedBy: nil,
            createdAt: Date().addingTimeInterval(-14400),
            completedAt: nil,
            distance: 3.4
        ),
        Task(
            id: UUID(),
            title: "Levere gamle møbler",
            description: "Sofa og bord som skal til Fretex. Står klart i garasjen.",
            category: .other,
            status: .active,
            price: 200,
            images: [],
            pickupLocation: Location(address: "Majorstuen, Oslo", latitude: 59.9298, longitude: 10.7127, city: "Oslo"),
            deliveryLocation: nil,
            createdBy: users[1],
            acceptedBy: nil,
            createdAt: Date().addingTimeInterval(-28800),
            completedAt: nil,
            distance: 1.8
        ),
    ]

    static let categories: [(TaskCategory, String)] = [
        (.transport, "Transport"),
        (.moving, "Flyttehjelp"),
        (.recycling, "Gjenvinning"),
        (.pickup, "Henting"),
        (.other, "Annet")
    ]

    // MARK: - Mock aktiv ordre

    static let mockActiveOrder = ActiveOrder(
        id: UUID(),
        task: tasks[0],
        phase: .enRoute,
        assignedHelper: users[0],
        estimatedArrival: 8,
        startedAt: Date().addingTimeInterval(-300),
        messages: [
            ChatMessage(id: UUID(), senderId: users[0].id, senderName: "Ola Nordmann", content: "Hei! Jeg er på vei nå", timestamp: Date().addingTimeInterval(-120)),
            ChatMessage(id: UUID(), senderId: currentUser.id, senderName: "Simen", content: "Topp! Jeg er hjemme", timestamp: Date().addingTimeInterval(-60)),
        ]
    )

    // MARK: - Mock feed

    static let feedItems: [FeedItem] = [
        FeedItem(id: UUID(), type: .needsHelp, task: tasks[0], postedAgo: "2 min siden"),
        FeedItem(id: UUID(), type: .freeItem, task: tasks[1], postedAgo: "15 min siden"),
        FeedItem(id: UUID(), type: .needsHelp, task: tasks[2], postedAgo: "1 time siden"),
        FeedItem(id: UUID(), type: .needsHelp, task: tasks[3], postedAgo: "2 timer siden"),
        FeedItem(id: UUID(), type: .freeItem, task: tasks[4], postedAgo: "3 timer siden"),
    ]

    // MARK: - Mock ordrehistorikk

    static var completedOrders: [ActiveOrder] {
        [
            ActiveOrder(
                id: UUID(),
                task: Task(id: UUID(), title: "Flytte vaskemaskin", description: "Gammel vaskemaskin ned fra 3. etasje", category: .moving, status: .completed, price: 300, images: [], pickupLocation: Location(address: "Grünerløkka, Oslo", latitude: 59.9226, longitude: 10.7594, city: "Oslo"), deliveryLocation: nil, createdBy: currentUser, acceptedBy: users[1], createdAt: Date().addingTimeInterval(-86400 * 3), completedAt: Date().addingTimeInterval(-86400 * 3 + 3600), distance: 0),
                phase: .completed,
                assignedHelper: users[1],
                estimatedArrival: nil,
                startedAt: Date().addingTimeInterval(-86400 * 3),
                messages: []
            ),
            ActiveOrder(
                id: UUID(),
                task: Task(id: UUID(), title: "Kjøre til gjenvinning", description: "Diverse elektrisk avfall", category: .recycling, status: .completed, price: 250, images: [], pickupLocation: Location(address: "Frogner, Oslo", latitude: 59.9193, longitude: 10.7018, city: "Oslo"), deliveryLocation: nil, createdBy: currentUser, acceptedBy: users[0], createdAt: Date().addingTimeInterval(-86400 * 7), completedAt: Date().addingTimeInterval(-86400 * 7 + 5400), distance: 0),
                phase: .completed,
                assignedHelper: users[0],
                estimatedArrival: nil,
                startedAt: Date().addingTimeInterval(-86400 * 7),
                messages: []
            )
        ]
    }
}
