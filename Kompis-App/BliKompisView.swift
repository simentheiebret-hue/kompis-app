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
    @State private var vilkaar1 = false  // Personlig ansvar
    @State private var vilkaar2 = false  // Skatteplikt
    @State private var vilkaar3 = false  // Plattformvilkår
    @State private var isRegistering = false
    @State private var soeknadSendt = false
    @State private var visError = false
    @State private var feilmelding: String? = nil

    private var alleVilkaarGodtatt: Bool {
        vilkaar1 && vilkaar2 && vilkaar3
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xxl) {

                    // MARK: - Header
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.kompisPrimary.opacity(0.12))
                                .frame(width: 90, height: 90)
                            Image(systemName: "hands.clap.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.kompisPrimary)
                        }

                        Text("Bli en Kompis")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.kompisTextPrimary)

                        Text("Hjelp folk i nabolaget og tjen penger på det du allerede kan")
                            .font(.system(size: 15))
                            .foregroundColor(.kompisTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xl)
                    }
                    .padding(.top, Spacing.xl)

                    // MARK: - Biltype-velger
                    if !soeknadSendt {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            SeksjonOverskrift("Hvilken bil har du?")

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
                        }
                        .padding(.horizontal, Spacing.lg)

                        // MARK: - Viktige vilkår
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            SeksjonOverskrift("Viktige vilkår")

                            VStack(spacing: 0) {
                                VilkaarRad(
                                    erHuket: $vilkaar1,
                                    ikon: "person.fill.checkmark",
                                    tekst: "Jeg er personlig ansvarlig for oppdragene jeg tar og kun jeg har lov til å bruke denne kontoen."
                                )
                                Divider().padding(.leading, 52)

                                VilkaarRad(
                                    erHuket: $vilkaar2,
                                    ikon: "building.columns.fill",
                                    tekst: "Jeg er ansvarlig for å rapportere inntekten min til skattemyndighetene."
                                )
                                Divider().padding(.leading, 52)

                                VilkaarRad(
                                    erHuket: $vilkaar3,
                                    ikon: "doc.text.fill",
                                    tekst: "Jeg godtar Kompis' brukervilkår og personvernregler."
                                )
                            }
                            .background(Color.kompisBgCard)
                            .cornerRadius(CornerRadius.xl)
                        }
                        .padding(.horizontal, Spacing.lg)
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
                            style: alleVilkaarGodtatt ? .primary : .secondary,
                            icon: isRegistering ? nil : "paperplane.fill"
                        ) {
                            guard alleVilkaarGodtatt,
                                  !isRegistering,
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
                        .disabled(!alleVilkaarGodtatt || isRegistering)

                        if !alleVilkaarGodtatt {
                            Text("Huk av alle vilkårene for å fortsette")
                                .font(.system(size: 12))
                                .foregroundColor(.kompisTextMuted)
                        }
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

// MARK: - Seksjon-overskrift

private struct SeksjonOverskrift: View {
    let tekst: String
    init(_ tekst: String) { self.tekst = tekst }

    var body: some View {
        Text(tekst)
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(.kompisTextPrimary)
    }
}

// MARK: - Vilkår-rad med avkrysning

private struct VilkaarRad: View {
    @Binding var erHuket: Bool
    let ikon: String
    let tekst: String

    var body: some View {
        Button(action: { erHuket.toggle() }) {
            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: ikon)
                    .font(.system(size: 18))
                    .foregroundColor(.kompisPrimary)
                    .frame(width: 28)
                    .padding(.top, 2)

                Text(tekst)
                    .font(.system(size: 14))
                    .foregroundColor(.kompisTextPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(erHuket ? Color.kompisPrimary : Color.kompisTextMuted, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if erHuket {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.kompisPrimary)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 2)
                .animation(.spring(response: 0.2), value: erHuket)
            }
            .padding(Spacing.lg)
        }
        .buttonStyle(PlainButtonStyle())
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
                .animation(.spring(response: 0.2), value: erValgt)
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
