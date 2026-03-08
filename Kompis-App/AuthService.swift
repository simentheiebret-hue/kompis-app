//
//  AuthService.swift
//  Kompis-App
//
//  Created by Claude on 23/02/2026.
//

import Foundation
import Combine
import UIKit

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var pendingConfirmationEmail: String?

    init() {
        sjekkSesjon()
    }

    func sjekkSesjon() {
        _Concurrency.Task {
            do {
                let result = try await SupabaseAuth.hentSession()
                let profil = try await SupabaseAuth.hentProfil(userId: result.userId)
                let user = lagUser(fra: profil)
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }
        }
    }

    func registrer(email: String, password: String, name: String) {
        DispatchQueue.main.async { self.isLoading = true; self.errorMessage = nil }
        _Concurrency.Task {
            do {
                let userId = try await SupabaseAuth.registrer(email: email, password: password, name: name)
                // Prøv å hente profil – fungerer kun hvis e-post er auto-bekreftet
                do {
                    let profil = try await SupabaseAuth.hentProfil(userId: userId)
                    let user = self.lagUser(fra: profil)
                    DispatchQueue.main.async {
                        self.currentUser = user
                        self.isAuthenticated = true
                        self.isLoading = false
                    }
                } catch {
                    // E-postbekreftelse er påkrevd
                    DispatchQueue.main.async {
                        self.pendingConfirmationEmail = email
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Registrering feilet: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    func loggInn(email: String, password: String) {
        DispatchQueue.main.async { self.isLoading = true; self.errorMessage = nil }
        _Concurrency.Task {
            do {
                let userId = try await SupabaseAuth.loggInn(email: email, password: password)
                let profil = try await SupabaseAuth.hentProfil(userId: userId)
                let user = lagUser(fra: profil)
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Feil e-post eller passord"
                    self.isLoading = false
                }
            }
        }
    }

    func bekreftOTP(email: String, kode: String) {
        DispatchQueue.main.async { self.isLoading = true; self.errorMessage = nil }
        _Concurrency.Task {
            do {
                let userId = try await SupabaseAuth.bekreftOTP(email: email, kode: kode)
                let profil = try await SupabaseAuth.hentProfil(userId: userId)
                let user = lagUser(fra: profil)
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.pendingConfirmationEmail = nil
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Feil kode, prøv igjen"
                    self.isLoading = false
                }
            }
        }
    }

    func loggInnMedGoogle() {
        DispatchQueue.main.async { self.isLoading = true; self.errorMessage = nil }
        _Concurrency.Task { @MainActor in
            do {
                let (userId, email, name) = try await SupabaseAuth.loggInnMedGoogle()
                let profil: ProfilData
                do {
                    profil = try await SupabaseAuth.hentProfil(userId: userId)
                } catch {
                    try await SupabaseAuth.opprettProfil(id: userId, name: name, email: email)
                    profil = try await SupabaseAuth.hentProfil(userId: userId)
                }
                let user = self.lagUser(fra: profil)
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            } catch {
                let nsError = error as NSError
                // Ignorer hvis brukeren trykket Avbryt i Safari
                let avbruttAvBruker = nsError.domain == "com.apple.AuthenticationServices.WebAuthenticationSession" && nsError.code == 1
                if !avbruttAvBruker {
                    self.errorMessage = "Kunne ikke fullføre Google-innlogging"
                }
                self.isLoading = false
            }
        }
    }

    func haandterOAuthCallback(url: URL) {
        _Concurrency.Task {
            do {
                let (userId, email, name) = try await SupabaseAuth.haandterOAuthURL(url)
                let profil: ProfilData
                do {
                    profil = try await SupabaseAuth.hentProfil(userId: userId)
                } catch {
                    try await SupabaseAuth.opprettProfil(id: userId, name: name, email: email)
                    profil = try await SupabaseAuth.hentProfil(userId: userId)
                }
                let user = lagUser(fra: profil)
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            } catch {
                // URL var ikke en auth-callback, ignorer
            }
        }
    }

    func triggerLoggUt() {
        _Concurrency.Task {
            do {
                try await SupabaseAuth.loggUt()
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Utlogging feilet"
                }
            }
        }
    }

    private func lagUser(fra profil: ProfilData) -> User {
        return User(
            id: UUID(uuidString: profil.id) ?? UUID(),
            name: profil.name,
            email: profil.email,
            phone: profil.phone,
            avatarURL: nil,
            rating: profil.rating,
            completedTasks: profil.completedTasks,
            isVerified: profil.isVerified,
            memberSince: profil.memberSince,
            co2Saved: profil.co2Saved,
            vehicleDescription: profil.vehicleDescription
        )
    }
}
