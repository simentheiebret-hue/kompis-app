//
//  SupabaseAuth.swift
//  Kompis-App
//
//  Isolerer alle Supabase-kall slik at de ikke forstyrrer SwiftUI-filer
//

import Foundation
import Supabase
import AuthenticationServices

struct SupabaseAuth {

    static func hentSession() async throws -> (userId: UUID, email: String) {
        let session = try await supabase.auth.session
        return (userId: session.user.id, email: session.user.email ?? "")
    }

    static func registrer(email: String, password: String, name: String) async throws -> UUID {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(name)]
        )
        return response.user.id
    }

    static func loggInn(email: String, password: String) async throws -> UUID {
        let session = try await supabase.auth.signIn(email: email, password: password)
        return session.user.id
    }

    static func loggUt() async throws {
        try await supabase.auth.signOut()
    }

    static func bekreftOTP(email: String, kode: String) async throws -> UUID {
        let session = try await supabase.auth.verifyOTP(
            email: email,
            token: kode,
            type: .signup
        )
        return session.user.id
    }

    static func opprettProfil(id: UUID, name: String, email: String) async throws {
        try await supabase
            .from("profiles")
            .insert(["id": id.uuidString, "name": name, "email": email])
            .execute()
    }

    @MainActor
    static func loggInnMedGoogle() async throws -> (userId: UUID, email: String, name: String) {
        let session = try await supabase.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "kompis-app://login-callback")!
        ) { url in
            try await åpneWebAuth(url: url)
        }
        var name = "Bruker"
        if case .string(let n) = session.user.userMetadata["full_name"] { name = n }
        else if case .string(let n) = session.user.userMetadata["name"] { name = n }
        return (userId: session.user.id, email: session.user.email ?? "", name: name)
    }

    @MainActor
    private static func åpneWebAuth(url: URL) async throws -> URL {
        let holder = WebAuthHolder()
        return try await withCheckedThrowingContinuation { continuation in
            let webSession = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "kompis-app"
            ) { callbackURL, error in
                _ = holder
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            webSession.presentationContextProvider = holder.contextProvider
            webSession.prefersEphemeralWebBrowserSession = false
            holder.session = webSession
            webSession.start()
        }
    }

    static func haandterOAuthURL(_ url: URL) async throws -> (userId: UUID, email: String, name: String) {
        let session = try await supabase.auth.session(from: url)
        var name = "Bruker"
        if case .string(let n) = session.user.userMetadata["full_name"] { name = n }
        else if case .string(let n) = session.user.userMetadata["name"] { name = n }
        return (userId: session.user.id, email: session.user.email ?? "", name: name)
    }

    static func hentProfil(userId: UUID) async throws -> ProfilData {
        let profil: ProfilData = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
        return profil
    }
}

// MARK: - Hjelpeklasser for ASWebAuthenticationSession

private class WebAuthHolder {
    var session: ASWebAuthenticationSession?
    let contextProvider = WebAuthContextProvider()
}

private class WebAuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}

struct ProfilData: Decodable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let rating: Double
    let completedTasks: Int
    let isVerified: Bool
    let memberSince: Date
    let co2Saved: Double
    let vehicleDescription: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, rating
        case completedTasks = "completed_tasks"
        case isVerified = "is_verified"
        case memberSince = "member_since"
        case co2Saved = "co2_saved"
        case vehicleDescription = "vehicle_description"
    }
}
