//
//  HomeView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showBookingFlow = false
    @State private var bookingCategory: TaskCategory = .transport
    @State private var showActiveOrder = false
    @State private var hasActiveOrder = true // Mock: simuler aktiv bestilling

    let categories = TaskCategory.allCases

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Hei, \(MockData.currentUser.name)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.kompisTextPrimary)
                        Text("Hva trenger du hjelp med?")
                            .font(.system(size: 16))
                            .foregroundColor(.kompisTextSecondary)
                    }
                    .padding(.horizontal, Spacing.lg)

                    // MARK: - Kategori-velger (åpner booking flow direkte)
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: Spacing.md),
                            GridItem(.flexible(), spacing: Spacing.md),
                            GridItem(.flexible(), spacing: Spacing.md)
                        ], spacing: Spacing.md) {
                            ForEach(categories, id: \.self) { category in
                                QuickCategoryButton(
                                    category: category,
                                    isSelected: false
                                ) {
                                    bookingCategory = category
                                    showBookingFlow = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)

                    // MARK: - Aktiv ordre-banner
                    if hasActiveOrder {
                        ActiveOrderBanner(order: MockData.mockActiveOrder) {
                            showActiveOrder = true
                        }
                        .padding(.horizontal, Spacing.lg)
                    }

                    // MARK: - Slik fungerer Kompis
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Slik fungerer det")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.kompisTextPrimary)

                        KompisCard {
                            VStack(spacing: Spacing.lg) {
                                HowItWorksRow(number: "1", icon: "camera.fill", title: "Ta et bilde", description: "Vis hva du trenger hjelp med")
                                Divider()
                                HowItWorksRow(number: "2", icon: "text.alignleft", title: "Beskriv kort", description: "Fortell hva som skal gjøres")
                                Divider()
                                HowItWorksRow(number: "3", icon: "car.fill", title: "Velg biltype", description: "Personbil, varebil eller lastebil")
                                Divider()
                                HowItWorksRow(number: "4", icon: "checkmark.circle.fill", title: "Hjelpen er på vei", description: "Følg med i sanntid")
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)

                    // MARK: - Nærme oppdrag (teaser)
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            Text("I nærheten")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.kompisTextPrimary)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.kompisPrimary)
                        }

                        ForEach(MockData.tasks.prefix(2)) { task in
                            NearbyTaskRow(task: task)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)

                    Spacer(minLength: 120)
                }
                .padding(.top, Spacing.lg)
            }
            .background(Color.kompisBgPrimary)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showBookingFlow) {
                BookingFlowView(category: bookingCategory) {
                    hasActiveOrder = true
                    showActiveOrder = true
                }
            }
            .fullScreenCover(isPresented: $showActiveOrder) {
                ActiveOrderView(
                    order: MockData.mockActiveOrder,
                    onDismiss: { showActiveOrder = false }
                )
            }
        }
    }
}

// MARK: - Quick Category Button

struct QuickCategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(isSelected ?
                            Color.kompisPrimary :
                            Color.kompisBgSecondary
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .kompisPrimary)
                }

                Text(category.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .kompisPrimary : .kompisTextSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Active Order Banner

struct ActiveOrderBanner: View {
    let order: ActiveOrder
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Pulserende sirkel
                ZStack {
                    Circle()
                        .fill(Color.kompisSuccess.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Circle()
                        .fill(Color.kompisSuccess)
                        .frame(width: 12, height: 12)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(phaseText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    if let eta = order.estimatedArrival {
                        Text("Ankommer om ca. \(eta) min")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(Spacing.lg)
            .background(
                LinearGradient(
                    colors: [Color.kompisPrimary, Color.kompisAccent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(CornerRadius.lg)
            .kompisShadow()
        }
    }

    var phaseText: String {
        switch order.phase {
        case .searching: return "Finner en Kompis..."
        case .matched: return "Kompis funnet!"
        case .enRoute: return "Hjelp er på vei"
        case .arrived: return "Kompisen er fremme"
        case .inProgress: return "Oppdraget pågår"
        case .completed: return "Fullført!"
        default: return ""
        }
    }
}

// MARK: - Nearby Task Row

struct NearbyTaskRow: View {
    let task: Task

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.kompisBgSecondary)
                    .frame(width: 52, height: 52)

                Image(systemName: task.category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(.kompisAccent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.kompisTextPrimary)
                    .lineLimit(1)
                HStack(spacing: Spacing.xs) {
                    Text(task.pickupLocation.city ?? "Oslo")
                    Text("·")
                    Text(String(format: "%.1f km", task.distance))
                }
                .font(.system(size: 13))
                .foregroundColor(.kompisTextSecondary)
            }

            Spacer()

            Text("\(task.price) kr")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.kompisPrimary)
        }
        .padding(Spacing.md)
        .background(Color.kompisBgCard)
        .cornerRadius(CornerRadius.md)
        .kompisShadow()
    }
}

// MARK: - How It Works Row (oppdatert)

struct HowItWorksRow: View {
    let number: String
    var icon: String = ""
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Text(number)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.kompisPrimary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.kompisTextPrimary)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.kompisTextSecondary)
            }

            Spacer()
        }
    }
}
