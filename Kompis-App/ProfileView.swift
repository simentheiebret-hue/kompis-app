//
//  ProfileView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(ProfileService.self) var profileService
    @State private var visBliKompis = false

    var user: User {
        authService.currentUser ?? MockData.currentUser
    }

    func handleLoggUt() {
        authService.triggerLoggUt()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Profil-header
                    VStack(spacing: Spacing.md) {
                        Circle()
                            .fill(Color.kompisBgSecondary)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String(user.name.prefix(1)))
                                    .font(.system(size: 40, weight: .semibold))
                                    .foregroundColor(.kompisTextSecondary)
                            )

                        Text(user.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.kompisTextPrimary)

                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", user.rating))
                            Text("•")
                            Text("\(user.completedTasks) oppdrag")
                            if user.isVerified {
                                Text("•")
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.kompisPrimary)
                                Text("Verifisert")
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.kompisTextSecondary)

                        Button("Rediger profil") {}
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.kompisPrimary)
                    }
                    .padding(.top, Spacing.xl)

                    // Statistikk
                    HStack(spacing: Spacing.lg) {
                        StatBox(value: "\(user.completedTasks)", label: "Fullført")
                        StatBox(value: "8", label: "Som hjelper")
                        StatBox(value: String(format: "%.1f", user.rating), label: "Rating")
                    }
                    .padding(.horizontal, Spacing.lg)

                    // Kompis-status-kort
                    if profileService.isHelper {
                        // Godkjent
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.kompisPrimary)
                            Text("Du er registrert som Kompis ✓")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.kompisTextPrimary)
                            Spacer()
                        }
                        .padding(Spacing.lg)
                        .background(Color.kompisPrimary.opacity(0.08))
                        .cornerRadius(CornerRadius.xl)
                        .padding(.horizontal, Spacing.lg)

                    } else if profileService.isPending {
                        // Venter på godkjenning
                        HStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color.kompisAccent.opacity(0.12))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.kompisAccent)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Søknad under behandling")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.kompisTextPrimary)
                                Text("Du får beskjed når du er godkjent")
                                    .font(.system(size: 13))
                                    .foregroundColor(.kompisTextSecondary)
                            }
                            Spacer()
                        }
                        .padding(Spacing.lg)
                        .background(Color.kompisAccent.opacity(0.08))
                        .cornerRadius(CornerRadius.xl)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.xl)
                                .stroke(Color.kompisAccent.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, Spacing.lg)

                    } else {
                        // Ikke søkt — vis "Bli Kompis"-kort
                        Button { visBliKompis = true } label: {
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Color.kompisPrimary.opacity(0.12))
                                        .frame(width: 52, height: 52)
                                    Image(systemName: "hands.clap.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.kompisPrimary)
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Bli en Kompis")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.kompisTextPrimary)
                                    Text("Hjelp naboer og tjen penger")
                                        .font(.system(size: 13))
                                        .foregroundColor(.kompisTextSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.kompisTextMuted)
                            }
                            .padding(Spacing.lg)
                            .background(
                                LinearGradient(
                                    colors: [Color.kompisPrimary.opacity(0.08), Color.kompisAccent.opacity(0.08)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(CornerRadius.xl)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.xl)
                                    .stroke(Color.kompisPrimary.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, Spacing.lg)
                        .sheet(isPresented: $visBliKompis) {
                            BliKompisView()
                        }
                    }

                    // CO2-sparing
                    CO2Card(co2Saved: user.co2Saved)
                        .padding(.horizontal, Spacing.lg)

                    // Meny
                    VStack(spacing: 0) {
                        ProfileMenuItem(icon: "creditcard.fill", title: "Betalingsmetoder")
                        ProfileMenuItem(icon: "mappin.circle.fill", title: "Mine adresser")
                        ProfileMenuItem(icon: "bell.fill", title: "Varsler")
                        ProfileMenuItem(icon: "questionmark.circle.fill", title: "Hjelp & support")
                    }
                    .background(Color.kompisBgCard)
                    .cornerRadius(CornerRadius.lg)
                    .padding(.horizontal, Spacing.lg)

                    // Logg ut
                    Button(action: handleLoggUt) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "arrow.right.square")
                            Text("Logg ut")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .foregroundColor(.kompisPrimary)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.pill)
                                .stroke(Color.kompisPrimary, lineWidth: 2)
                        )
                    }
                    .padding(.horizontal, Spacing.lg)

                    Spacer(minLength: 100)
                }
            }
            .background(Color.kompisBgPrimary)
            .navigationBarHidden(true)
        }
    }
}

struct CO2Card: View {
    let co2Saved: Double

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 32))
                .foregroundColor(.kompisPrimary)
            Text("Du har spart miljøet for")
                .font(.system(size: 14))
                .foregroundColor(.kompisTextSecondary)
            Text("\(Int(co2Saved)) kg CO₂")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.kompisPrimary)
            Text("ved å gjenbruke og resirkulere!")
                .font(.system(size: 14))
                .foregroundColor(.kompisTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.kompisBgCard)
        .cornerRadius(CornerRadius.lg)
        .kompisShadow()
    }
}

struct StatBox: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.kompisTextPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.kompisTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .background(Color.kompisBgCard)
        .cornerRadius(CornerRadius.md)
        .kompisShadow()
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.kompisPrimary)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.kompisTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.kompisTextMuted)
        }
        .padding(Spacing.lg)
    }
}
