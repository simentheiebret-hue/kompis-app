//
//  TaskDetailView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct TaskDetailView: View {
    let task: Task
    @Environment(\.dismiss) private var dismiss
    @Environment(TaskService.self) private var taskService
    @Environment(ProfileService.self) private var profileService
    @EnvironmentObject private var authService: AuthService

    @State private var harSoekt = false
    @State private var isSending = false
    @State private var visError = false
    @State private var feilmelding: String? = nil
    @State private var visBliKompis = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Bilde
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Color.kompisBgSecondary)
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: task.category.icon)
                                .font(.system(size: 60))
                                .foregroundColor(.kompisTextMuted)
                        )
                    
                    // Tilbake-knapp
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.kompisTextPrimary)
                            .padding(Spacing.md)
                            .background(Color.kompisBgCard.opacity(0.9))
                            .clipShape(Circle())
                    }
                    .padding(Spacing.lg)
                }
                
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Tittel og badge
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        KompisBadge(text: task.category.rawValue, variant: .category)
                        
                        Text(task.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.kompisTextPrimary)
                        
                        HStack(spacing: Spacing.lg) {
                            KompisBadge(text: "\(task.price) kr", variant: .price)
                            
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.kompisAccent)
                                Text(String(format: "%.1f km fra deg", task.distance))
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.kompisTextSecondary)
                        }
                    }
                    
                    Divider()
                    
                    // Beskrivelse
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Om oppdraget")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.kompisTextPrimary)
                        
                        Text(task.description)
                            .font(.system(size: 15))
                            .foregroundColor(.kompisTextSecondary)
                            .lineSpacing(4)
                    }
                    
                    Divider()
                    
                    // Lokasjon
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Lokasjon")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.kompisTextPrimary)
                        
                        // Kart placeholder
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .fill(Color.kompisBgSecondary)
                            .frame(height: 150)
                            .overlay(
                                Image(systemName: "map")
                                    .font(.system(size: 40))
                                    .foregroundColor(.kompisTextMuted)
                            )
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.kompisSecondary)
                            Text("Hentes: \(task.pickupLocation.address)")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.kompisTextSecondary)
                        
                        if let delivery = task.deliveryLocation {
                            HStack {
                                Image(systemName: "flag.circle.fill")
                                    .foregroundColor(.kompisPrimary)
                                Text("Leveres: \(delivery.address)")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.kompisTextSecondary)
                        }
                    }
                    
                    Divider()
                    
                    // Oppdragsgiver
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Oppdragsgiver")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.kompisTextPrimary)
                        
                        KompisCard {
                            HStack(spacing: Spacing.md) {
                                Circle()
                                    .fill(Color.kompisBgSecondary)
                                    .frame(width: 56, height: 56)
                                    .overlay(
                                        Text(String(task.createdBy.name.prefix(1)))
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(.kompisTextSecondary)
                                    )
                                
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text(task.createdBy.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.kompisTextPrimary)
                                    
                                    HStack(spacing: Spacing.sm) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text(String(format: "%.1f", task.createdBy.rating))
                                        Text("•")
                                        Text("\(task.createdBy.completedTasks) oppdrag")
                                    }
                                    .font(.system(size: 13))
                                    .foregroundColor(.kompisTextSecondary)
                                    
                                    if task.createdBy.isVerified {
                                        HStack(spacing: Spacing.xs) {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(.kompisPrimary)
                                            Text("Verifisert med BankID")
                                        }
                                        .font(.system(size: 12))
                                        .foregroundColor(.kompisPrimary)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Knapp — avhenger av rolle
                    let erEgenOppgave = authService.currentUser?.id == task.createdBy.id
                    if erEgenOppgave {
                        // Oppdragsgiver ser sitt eget oppdrag — ingen knapp ennå
                        EmptyView()
                    } else if profileService.isHelper {
                        // Registrert kompis kan søke
                        KompisButton(
                            title: harSoekt ? "Søknad sendt ✓" : (isSending ? "Sender…" : "Jeg vil hjelpe!"),
                            style: harSoekt ? .secondary : .primary,
                            icon: harSoekt ? "checkmark.circle.fill" : "checkmark"
                        ) {
                            guard !harSoekt, !isSending,
                                  let userId = authService.currentUser?.id else { return }
                            isSending = true
                            _Concurrency.Task {
                                do {
                                    try await taskService.sendSoeknad(taskId: task.id, applicantId: userId)
                                    harSoekt = true
                                } catch {
                                    feilmelding = error.localizedDescription
                                    visError = true
                                }
                                isSending = false
                            }
                        }
                        .disabled(harSoekt || isSending)
                    } else {
                        // Ikke registrert som kompis ennå
                        Button {
                            visBliKompis = true
                        } label: {
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Color.kompisPrimary.opacity(0.12))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "hands.clap.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.kompisPrimary)
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Vil du hjelpe?")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.kompisTextPrimary)
                                    Text("Registrer deg som Kompis for å søke")
                                        .font(.system(size: 13))
                                        .foregroundColor(.kompisTextSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.kompisTextMuted)
                            }
                            .padding(Spacing.lg)
                            .background(Color.kompisBgCard)
                            .cornerRadius(CornerRadius.lg)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.lg)
                                    .stroke(Color.kompisPrimary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $visBliKompis) {
                            BliKompisView()
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(Spacing.lg)
            }
        }
        .background(Color.kompisBgPrimary)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .task {
            if let userId = authService.currentUser?.id {
                harSoekt = await taskService.harSoekt(taskId: task.id, applicantId: userId)
            }
        }
        .alert("Noe gikk galt", isPresented: $visError) {
            Button("OK") { }
        } message: {
            Text(feilmelding ?? "Prøv igjen")
        }
    }
}
