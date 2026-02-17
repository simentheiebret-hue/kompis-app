//
//  ProfileView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct ProfileView: View {
    let user = MockData.currentUser
    
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
                    
                    // CO2-sparing
                    KompisCard {
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.kompisPrimary)
                            
                            Text("Du har spart miljøet for")
                                .font(.system(size: 14))
                                .foregroundColor(.kompisTextSecondary)
                            
                            Text("\(Int(user.co2Saved)) kg CO₂")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.kompisPrimary)
                            
                            Text("ved å gjenbruke og resirkulere!")
                                .font(.system(size: 14))
                                .foregroundColor(.kompisTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                    }
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
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color.kompisBgPrimary)
            .navigationBarHidden(true)
        }
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
