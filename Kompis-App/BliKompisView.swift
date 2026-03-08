//
//  BliKompisView.swift
//  Kompis-App
//

import SwiftUI

struct BliKompisView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProfileService.self) private var profileService
    @EnvironmentObject private var authService: AuthService

    @State private var valgtBiltype: VehicleType = .personbil
    @State private var isRegistering = false
    @State private var soeknadSendt = false
    @State private var visError = false
    @State private var feilmelding: String? = nil

    private let fordeler: [(emoji: String, tittel: String, undertekst: String)] = [
        ("💰", "Tjen 100–500 kr per oppdrag", "Sett din egen pris og godta kun det du vil"),
        ("🕐", "Jobb når det passer deg", "Hjelp naboer på dine egne premisser"),
        ("🌱", "Gjør en forskjell", "Bygg tillit og fellesskap i nabolaget"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xl) {

                    // MARK: - Header
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.kompisPrimary.opacity(0.12))
                                .frame(width: 100, height: 100)
                            Image(systemName: "hands.clap.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.kompisPrimary)
                        }

                        Text("Bli en Kompis")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.kompisTextPrimary)

                        Text("Hjelp folk i nabolaget ditt og tjen penger på det du allerede kan")
                            .font(.system(size: 15))
                            .foregroundColor(.kompisTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xl)
                    }
                    .padding(.top, Spacing.xl)

                    // MARK: - Fordeler
                    VStack(spacing: 0) {
                        ForEach(fordeler.indices, id: \.self) { i in
                            HStack(alignment: .top, spacing: Spacing.md) {
                                Text(fordeler[i].emoji)
                                    .font(.system(size: 28))
                                    .frame(width: 44)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(fordeler[i].tittel)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.kompisTextPrimary)
                                    Text(fordeler[i].undertekst)
                                        .font(.system(size: 13))
                                        .foregroundColor(.kompisTextSecondary)
                                }

                                Spacer()
                            }
                            .padding(Spacing.lg)

                            if i < fordeler.count - 1 {
                                Divider().padding(.leading, 60)
                            }
                        }
                    }
                    .background(Color.kompisBgCard)
                    .cornerRadius(CornerRadius.xl)
                    .padding(.horizontal, Spacing.lg)

                    // MARK: - Biltype-velger
                    if !soeknadSendt {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Hvilken bil har du?")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.kompisTextPrimary)
                                .padding(.horizontal, Spacing.lg)

                            VStack(spacing: Spacing.sm) {
                                ForEach(VehicleType.allCases, id: \.self) { biltype in
                                    BiltypeRadioRow(
                                        biltype: biltype,
                                        erValgt: valgtBiltype == biltype
                                    ) {
                                        valgtBiltype = biltype
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                    }

                    // MARK: - Søknad sendt
                    if soeknadSendt {
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "clock.badge.checkmark.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.kompisAccent)
                            Text("Søknad sendt! 📋")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.kompisTextPrimary)
                            Text("Vi behandler søknaden din. Du får beskjed når du er godkjent som Kompis.")
                                .font(.system(size: 14))
                                .foregroundColor(.kompisTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.xl)
                        }
                        .padding(Spacing.xl)
                        .frame(maxWidth: .infinity)
                        .background(Color.kompisBgCard)
                        .cornerRadius(CornerRadius.xl)
                        .padding(.horizontal, Spacing.lg)
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer(minLength: 120)
                }
            }
            .background(Color.kompisBgPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Lukk") { dismiss() }
                        .foregroundColor(.kompisPrimary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: Spacing.sm) {
                    if soeknadSendt {
                        KompisButton(title: "Lukk", style: .secondary, icon: nil) {
                            dismiss()
                        }
                    } else {
                        KompisButton(
                            title: isRegistering ? "Sender søknad…" : "Send søknad",
                            style: .primary,
                            icon: isRegistering ? nil : "paperplane.fill"
                        ) {
                            guard !isRegistering,
                                  let user = authService.currentUser else { return }
                            isRegistering = true
                            _Concurrency.Task {
                                do {
                                    try await profileService.bliKompis(
                                        userId: user.id,
                                        name: user.name,
                                        email: user.email,
                                        vehicleType: valgtBiltype.rawValue
                                    )
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        soeknadSendt = true
                                    }
                                } catch {
                                    feilmelding = error.localizedDescription
                                    visError = true
                                }
                                isRegistering = false
                            }
                        }
                        .disabled(isRegistering)

                        Text("Gratis å søke. Vi kontakter deg så snart søknaden er behandlet.")
                            .font(.system(size: 12))
                            .foregroundColor(.kompisTextMuted)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
                .background(Color.kompisBgPrimary)
            }
            .alert("Noe gikk galt", isPresented: $visError) {
                Button("OK") { }
            } message: {
                Text(feilmelding ?? "Ukjent feil")
            }
        }
    }
}

// MARK: - Biltype-rad med radio-button

private struct BiltypeRadioRow: View {
    let biltype: VehicleType
    let erValgt: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(erValgt ? Color.kompisPrimary.opacity(0.12) : Color.kompisBgCard)
                        .frame(width: 48, height: 48)
                    Image(systemName: biltype.icon)
                        .font(.system(size: 22))
                        .foregroundColor(erValgt ? .kompisPrimary : .kompisTextSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(biltype.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.kompisTextPrimary)
                    Text(biltype.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.kompisTextSecondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(erValgt ? Color.kompisPrimary : Color.kompisTextMuted, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if erValgt {
                        Circle()
                            .fill(Color.kompisPrimary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(Color.kompisBgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(erValgt ? Color.kompisPrimary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
