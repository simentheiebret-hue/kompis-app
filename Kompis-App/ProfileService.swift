//
//  ProfileService.swift
//  Kompis-App
//

import Foundation
import Observation
import Supabase

struct ProfileRow: Decodable {
    let id: UUID
    let name: String
    let helperStatus: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case helperStatus = "helper_status"
    }
}

struct ProfileUpsert: Encodable {
    let id: UUID
    let name: String
    let email: String
    let helperStatus: String
    let vehicleType: String

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case helperStatus = "helper_status"
        case vehicleType = "vehicle_type"
    }
}

@Observable
class ProfileService {
    var helperStatus: String? = nil
    var isLoading = false

    var isHelper: Bool { helperStatus == "approved" }
    var isPending: Bool { helperStatus == "pending" }

    func hentProfil(userId: UUID) async {
        isLoading = true
        do {
            let profil: ProfileRow = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            helperStatus = profil.helperStatus
        } catch {
            helperStatus = nil
        }
        isLoading = false
    }

    func bliKompis(userId: UUID, name: String, email: String, vehicleType: String) async throws {
        try await supabase
            .from("profiles")
            .upsert(ProfileUpsert(
                id: userId,
                name: name,
                email: email,
                helperStatus: "pending",
                vehicleType: vehicleType
            ))
            .execute()
        helperStatus = "pending"
    }
}
