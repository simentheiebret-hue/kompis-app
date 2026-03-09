//
//  TaskService.swift
//  Kompis-App
//

import Foundation
import Observation
import Supabase
import UIKit

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
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, category, status, price
        case creatorId = "creator_id"
        case pickupAddress = "pickup_address"
        case pickupCity = "pickup_city"
        case createdAt = "created_at"
        case imageUrl = "image_url"
    }

    func tilKompisTask() -> KompisTask {
        let kat = TaskCategory(rawValue: category) ?? .other
        let loc = Location(address: pickupAddress, latitude: 0, longitude: 0,
                           city: pickupCity.isEmpty ? nil : pickupCity)
        let creator = User(id: creatorId, name: "Bruker", email: "", phone: nil,
                           avatarURL: nil, rating: 0, completedTasks: 0,
                           isVerified: false, memberSince: createdAt,
                           co2Saved: 0, vehicleDescription: nil)
        let images: [URL] = imageUrl.flatMap { URL(string: $0) }.map { [$0] } ?? []
        return KompisTask(id: id, title: title, description: description,
                          category: kat, status: .active, price: Int(price),
                          images: images, pickupLocation: loc, deliveryLocation: nil,
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
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case title, description, category, status, price
        case creatorId = "creator_id"
        case pickupAddress = "pickup_address"
        case pickupCity = "pickup_city"
        case imageUrl = "image_url"
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
    var mineOppdrag: [KompisTask] = []
    var isLoading = false

    func hentMineOppdrag(userId: UUID) {
        _Concurrency.Task {
            do {
                let rader: [TaskRow] = try await supabase
                    .from("tasks")
                    .select()
                    .eq("creator_id", value: userId.uuidString)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                mineOppdrag = rader.map { $0.tilKompisTask() }
            } catch {
                print("Feil ved henting av mine oppdrag: \(error)")
            }
        }
    }

    func hentOppdrag() {
        _Concurrency.Task { await refreshOppdrag() }
    }

    func refreshOppdrag() async {
        isLoading = true
        defer { isLoading = false }
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
    }

    func opprettOppdrag(category: TaskCategory, description: String,
                        address: String, price: Int, creatorId: UUID,
                        image: UIImage? = nil) async throws {
        let taskId = UUID()
        var imageUrl: String? = nil
        if let image {
            imageUrl = try await uploadBilde(image, taskId: taskId)
        }
        let nytt = NyttOppdrag(title: category.rawValue, description: description,
                               category: category.rawValue, status: "active",
                               price: Double(price), creatorId: creatorId,
                               pickupAddress: address, pickupCity: "",
                               imageUrl: imageUrl)
        try await supabase.from("tasks").insert(nytt).execute()
        await refreshOppdrag()
    }

    private func uploadBilde(_ image: UIImage, taskId: UUID) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Kunne ikke konvertere bilde"])
        }
        let path = "\(taskId.uuidString)/cover.jpg"
        try await supabase.storage
            .from("task-images")
            .upload(path, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
        let url = try supabase.storage
            .from("task-images")
            .getPublicURL(path: path)
        return url.absoluteString
    }

    func sendSoeknad(taskId: UUID, applicantId: UUID) async throws {
        let soeknad = NySoeknad(taskId: taskId, applicantId: applicantId, status: "pending")
        try await supabase.from("task_applications").insert(soeknad).execute()
    }

    func slettOppdrag(taskId: UUID) async throws {
        try await supabase.from("tasks")
            .delete()
            .eq("id", value: taskId.uuidString)
            .execute()
        tasks.removeAll { $0.id == taskId }
        mineOppdrag.removeAll { $0.id == taskId }
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
