//
//  TaskService.swift
//  Kompis-App
//

import Foundation
import Observation
import Supabase

struct TaskRow: Decodable {
    let id: UUID
    let title: String
    let description: String
    let category: String
    let status: String
    let price: Double
    let creatorId: UUID
    let pickupAddress: String
    let pickupCity: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description, category, status, price
        case creatorId = "creator_id"
        case pickupAddress = "pickup_address"
        case pickupCity = "pickup_city"
        case createdAt = "created_at"
    }

    func tilKompisTask() -> KompisTask {
        let kat = TaskCategory(rawValue: category) ?? .other
        let loc = Location(address: pickupAddress, latitude: 0, longitude: 0,
                           city: pickupCity.isEmpty ? nil : pickupCity)
        let creator = User(id: creatorId, name: "Bruker", email: "", phone: nil,
                           avatarURL: nil, rating: 0, completedTasks: 0,
                           isVerified: false, memberSince: createdAt,
                           co2Saved: 0, vehicleDescription: nil)
        return KompisTask(id: id, title: title, description: description,
                          category: kat, status: .active, price: Int(price),
                          images: [], pickupLocation: loc, deliveryLocation: nil,
                          createdBy: creator, acceptedBy: nil,
                          createdAt: createdAt, completedAt: nil, distance: 0)
    }
}

struct NyttOppdrag: Encodable {
    let title: String
    let description: String
    let category: String
    let status: String
    let price: Double
    let creatorId: UUID
    let pickupAddress: String
    let pickupCity: String

    enum CodingKeys: String, CodingKey {
        case title, description, category, status, price
        case creatorId = "creator_id"
        case pickupAddress = "pickup_address"
        case pickupCity = "pickup_city"
    }
}

struct ApplicationRow: Decodable {
    let id: UUID
    let taskId: UUID
    let applicantId: UUID
    let status: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, status
        case taskId = "task_id"
        case applicantId = "applicant_id"
        case createdAt = "created_at"
    }
}

struct NySoeknad: Encodable {
    let taskId: UUID
    let applicantId: UUID
    let status: String

    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case applicantId = "applicant_id"
        case status
    }
}

@Observable
class TaskService {
    var tasks: [KompisTask] = []
    var isLoading = false

    func hentOppdrag() {
        _Concurrency.Task {
            isLoading = true
            do {
                let rader: [TaskRow] = try await supabase
                    .from("tasks")
                    .select()
                    .eq("status", value: "active")
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                tasks = rader.map { $0.tilKompisTask() }
            } catch {
                print("Feil ved henting av oppdrag: \(error)")
            }
            isLoading = false
        }
    }

    func opprettOppdrag(category: TaskCategory, description: String,
                        address: String, price: Int, creatorId: UUID) async throws {
        let nytt = NyttOppdrag(title: category.rawValue, description: description,
                               category: category.rawValue, status: "active",
                               price: Double(price), creatorId: creatorId,
                               pickupAddress: address, pickupCity: "")
        try await supabase.from("tasks").insert(nytt).execute()
        hentOppdrag()
    }

    func sendSoeknad(taskId: UUID, applicantId: UUID) async throws {
        let soeknad = NySoeknad(taskId: taskId, applicantId: applicantId, status: "pending")
        try await supabase.from("task_applications").insert(soeknad).execute()
    }

    func harSoekt(taskId: UUID, applicantId: UUID) async -> Bool {
        do {
            let rader: [ApplicationRow] = try await supabase
                .from("task_applications")
                .select()
                .eq("task_id", value: taskId.uuidString)
                .eq("applicant_id", value: applicantId.uuidString)
                .execute()
                .value
            return !rader.isEmpty
        } catch {
            print("Feil ved søknad-sjekk: \(error)")
            return false
        }
    }
}
