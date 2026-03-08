//
//  AuthView.swift
//  Kompis-App
//
//  Created by Claude on 23/02/2026.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    @State private var visEpostSkjema = false

    var body: some View {
        ZStack {
            Color.kompisBgPrimary.ignoresSafeArea()

            VStack(spacing: Spacing.xxl) {

                Spacer()

                // MARK: - Logo
                VStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.kompisPrimary)
                            .frame(width: 90, height: 90)
                        Image(systemName: "hands.and.sparkles.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }

                    Text("Kompis")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisTextPrimary)

                    Text("Hjelp og bli hjulpet i nabolaget")
                        .font(.subheadline)
                        .foregroundColor(.kompisTextSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // MARK: - Innloggingsknapper
                VStack(spacing: Spacing.md) {

                    // Sign in with Apple
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        // Kobles til Supabase når Apple Developer-konto er klar
                        print("Apple sign in result: \(result)")
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 54)
                    .cornerRadius(CornerRadius.pill)

                    // Sign in with Google
                    Button(action: { authService.loggInnMedGoogle() }) {
                        HStack(spacing: Spacing.md) {
                            GoogleLogoView()
                            Text("Fortsett med Google")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.kompisBgCard)
                        .foregroundColor(.kompisTextPrimary)
                        .cornerRadius(CornerRadius.pill)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.pill)
                                .stroke(Color.kompisDivider, lineWidth: 1.5)
                        )
                    }

                    // Skillelinje
                    HStack {
                        Rectangle().fill(Color.kompisDivider).frame(height: 1)
                        Text("eller")
                            .font(.caption)
                            .foregroundColor(.kompisTextMuted)
                            .padding(.horizontal, Spacing.sm)
                        Rectangle().fill(Color.kompisDivider).frame(height: 1)
                    }

                    // E-post knapp
                    Button(action: { visEpostSkjema = true }) {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 18, weight: .medium))
                            Text("Fortsett med e-post")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.kompisSurface)
                        .foregroundColor(.kompisTextPrimary)
                        .cornerRadius(CornerRadius.pill)
                    }
                }
                .padding(.horizontal, Spacing.xl)

                // Vilkår
                Text("Ved å fortsette godtar du våre vilkår og personvernregler")
                    .font(.caption)
                    .foregroundColor(.kompisTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
            }
        }
        .sheet(isPresented: $visEpostSkjema) {
            EpostInnloggingView()
                .environmentObject(authService)
        }
    }
}

// MARK: - E-post innlogging (sheet)

struct EpostInnloggingView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    @State private var isLogin = true
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kompisBgPrimary.ignoresSafeArea()

                if let email = authService.pendingConfirmationEmail {
                    OTPBekreftelsesView(email: email)
                        .environmentObject(authService)
                } else {
                ScrollView {
                    VStack(spacing: Spacing.xl) {

                        // Toggle
                        HStack(spacing: 0) {
                            EpostTabButton(title: "Logg inn", isSelected: isLogin) {
                                withAnimation(.spring(response: 0.3)) { isLogin = true }
                            }
                            EpostTabButton(title: "Registrer deg", isSelected: !isLogin) {
                                withAnimation(.spring(response: 0.3)) { isLogin = false }
                            }
                        }
                        .background(Color.kompisSurface)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.pill))
                        .padding(.top, Spacing.lg)

                        // Skjema
                        VStack(spacing: Spacing.lg) {
                            if !isLogin {
                                EpostFelt(placeholder: "Fullt navn", icon: "person.fill", text: $name)
                                    .focused($focusedField, equals: .name)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .email }
                            }

                            EpostFelt(placeholder: "E-postadresse", icon: "envelope.fill", text: $email, keyboardType: .emailAddress)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .password }
                                .textInputAutocapitalization(.never)

                            EpostFelt(placeholder: "Passord", icon: "lock.fill", text: $password, isSecure: true)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.done)
                                .onSubmit { sendInn() }
                        }

                        // Feilmelding
                        if let error = authService.errorMessage {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(error).font(.subheadline)
                            }
                            .foregroundColor(.kompisError)
                        }

                        // Knapp
                        if authService.isLoading {
                            ProgressView().tint(.kompisPrimary).scaleEffect(1.3).frame(height: 54)
                        } else {
                            Button(action: sendInn) {
                                Text(isLogin ? "Logg inn" : "Opprett konto")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color.kompisPrimary)
                                    .cornerRadius(CornerRadius.pill)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                } // end else
            }
            .navigationTitle(isLogin ? "Logg inn" : "Registrer deg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                        .foregroundColor(.kompisPrimary)
                }
            }
        }
    }

    private func sendInn() {
        focusedField = nil
        if isLogin {
            authService.loggInn(email: email, password: password)
        } else {
            authService.registrer(email: email, password: password, name: name)
        }
    }
}

// MARK: - OTP-bekreftelse

struct OTPBekreftelsesView: View {
    @EnvironmentObject var authService: AuthService
    let email: String
    @State private var kode = ""
    @FocusState private var kodeFokusert: Bool

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Ikon og info
            VStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.green)
                }

                Text("Sjekk e-posten din")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.green)

                Text("Vi sendte en 6-sifret kode til\n\(email)")
                    .font(.subheadline)
                    .foregroundColor(.kompisTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // Kodefelt
            TextField("6-sifret kode", text: $kode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($kodeFokusert)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(Spacing.lg)
                .background(Color.kompisBgCard)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                .overlay(RoundedRectangle(cornerRadius: CornerRadius.lg).stroke(Color.green, lineWidth: 2))
                .onChange(of: kode) { _, ny in
                    kode = String(ny.filter(\.isNumber).prefix(6))
                }

            // Feilmelding
            if let feil = authService.errorMessage {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "xmark.circle.fill")
                    Text(feil).font(.subheadline)
                }
                .foregroundColor(.kompisError)
            }

            // Bekreft-knapp
            if authService.isLoading {
                ProgressView().tint(.kompisPrimary).scaleEffect(1.3).frame(height: 54)
            } else {
                Button(action: {
                    authService.bekreftOTP(email: email, kode: kode)
                }) {
                    Text("Bekreft konto")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(kode.count == 6 ? Color.kompisPrimary : Color.kompisTextMuted)
                        .cornerRadius(CornerRadius.pill)
                }
                .disabled(kode.count < 6)
            }

            // Avbryt
            Button("Avbryt") {
                authService.pendingConfirmationEmail = nil
                authService.errorMessage = nil
            }
            .font(.subheadline)
            .foregroundColor(.kompisTextSecondary)

            Spacer()
        }
        .padding(.horizontal, Spacing.xl)
        .onAppear { kodeFokusert = true }
    }
}

// MARK: - Google-logo

private struct GoogleLogoView: View {
    var body: some View {
        Image("GoogleLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 22, height: 22)
    }
}

// MARK: - Hjelpere

private struct EpostTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(isSelected ? .white : .kompisTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(isSelected ? Color.kompisPrimary : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.pill))
                .padding(4)
        }
    }
}

private struct EpostFelt: View {
    let placeholder: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(.kompisTextSecondary)
                .frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text).foregroundColor(.kompisTextPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(.kompisTextPrimary)
                    .autocorrectionDisabled()
            }
        }
        .padding(Spacing.lg)
        .background(Color.kompisBgCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: CornerRadius.lg).stroke(Color.kompisDivider, lineWidth: 1))
    }
}
