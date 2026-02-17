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
    @State private var hasActiveOrder = true
    @State private var headerOpacity: Double = 1.0

    let categories = TaskCategory.allCases

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // MARK: - Bakgrunn med mesh-gradient
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.kompisGradientTop,
                            Color.kompisGradientBottom,
                            Color(hex: "#0D2318")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Ambient orb øverst til venstre
                    Circle()
                        .fill(Color.kompisPrimary.opacity(0.35))
                        .frame(width: 320, height: 320)
                        .blur(radius: 80)
                        .offset(x: -80, y: -120)

                    // Amber orb nedre høyre
                    Circle()
                        .fill(Color.kompisSecondary.opacity(0.2))
                        .frame(width: 280, height: 280)
                        .blur(radius: 80)
                        .offset(x: 120, y: 300)
                }
                .ignoresSafeArea()

                // MARK: - Scrollbart innhold
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.xl) {

                        // MARK: - Hero Header
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("God dag,")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.kompisTextSecondary)
                                    Text(MockData.currentUser.name)
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(.kompisTextPrimary)
                                }

                                Spacer()

                                // Profilavatar
                                ZStack {
                                    Circle()
                                        .fill(Color.kompisAccent.opacity(0.3))
                                        .frame(width: 48, height: 48)
                                    Text(String(MockData.currentUser.name.prefix(1)))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.kompisTextPrimary)
                                }
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1.5))
                            }

                            Text("Hva trenger du hjelp med?")
                                .font(.system(size: 15))
                                .foregroundColor(.kompisTextSecondary)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)

                        // MARK: - Aktiv ordre-banner (glass)
                        if hasActiveOrder {
                            ActiveOrderBanner(order: MockData.mockActiveOrder) {
                                showActiveOrder = true
                            }
                            .padding(.horizontal, Spacing.lg)
                        }

                        // MARK: - Kategorikort (glass-grid)
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Bestill hjelp")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.kompisTextMuted)
                                .textCase(.uppercase)
                                .tracking(1.2)
                                .padding(.horizontal, Spacing.lg)

                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: Spacing.md),
                                GridItem(.flexible(), spacing: Spacing.md),
                                GridItem(.flexible(), spacing: Spacing.md)
                            ], spacing: Spacing.md) {
                                ForEach(categories, id: \.self) { category in
                                    QuickCategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        bookingCategory = category
                                        showBookingFlow = true
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.lg)
                        }

                        // MARK: - Slik fungerer Kompis (glass-kort)
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Slik fungerer det")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.kompisTextMuted)
                                .textCase(.uppercase)
                                .tracking(1.2)
                                .padding(.horizontal, Spacing.lg)

                            VStack(spacing: Spacing.lg) {
                                HowItWorksRow(number: "1", icon: "camera.fill",
                                              title: "Ta et bilde",
                                              description: "Vis hva du trenger hjelp med")
                                Rectangle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 1)
                                HowItWorksRow(number: "2", icon: "text.alignleft",
                                              title: "Beskriv kort",
                                              description: "Fortell hva som skal gjøres")
                                Rectangle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 1)
                                HowItWorksRow(number: "3", icon: "car.fill",
                                              title: "Velg biltype",
                                              description: "Personbil, varebil eller lastebil")
                                Rectangle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 1)
                                HowItWorksRow(number: "4", icon: "checkmark.circle.fill",
                                              title: "Hjelpen er på vei",
                                              description: "Følg med i sanntid")
                            }
                            .padding(Spacing.lg)
                            .glassCard(cornerRadius: CornerRadius.xl)
                            .padding(.horizontal, Spacing.lg)
                        }

                        // MARK: - I nærheten
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack {
                                Text("I nærheten")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.kompisTextMuted)
                                    .textCase(.uppercase)
                                    .tracking(1.2)
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("Se alle")
                                        .font(.system(size: 13, weight: .medium))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(.kompisSecondary)
                            }
                            .padding(.horizontal, Spacing.lg)

                            ForEach(MockData.tasks.prefix(2)) { task in
                                NearbyTaskRow(task: task)
                                    .padding(.horizontal, Spacing.lg)
                            }
                        }

                        Spacer(minLength: 130)
                    }
                }
            }
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

// MARK: - Quick Category Button (glass-stil)

struct QuickCategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    // Glass-sirkel bakgrunn
                    Circle()
                        .fill(
                            isSelected
                            ? Color.kompisSecondary.opacity(0.3)
                            : Color.white.opacity(0.08)
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected
                                    ? Color.kompisSecondary.opacity(0.6)
                                    : Color.white.opacity(0.15),
                                    lineWidth: 1.5
                                )
                        )

                    // Glød bak ikonet ved valg
                    if isSelected {
                        Circle()
                            .fill(Color.kompisSecondary.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .blur(radius: 10)
                    }

                    Image(systemName: category.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? Color.kompisSecondary : Color.kompisTextPrimary)
                }

                Text(category.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? Color.kompisSecondary : Color.kompisTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .scaleEffect(isPressed ? 0.93 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3)) { isPressed = false }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Active Order Banner (glass-stil)

struct ActiveOrderBanner: View {
    let order: ActiveOrder
    let onTap: () -> Void

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Pulserende live-indikator
                ZStack {
                    Circle()
                        .fill(Color.kompisSuccess.opacity(0.25))
                        .frame(width: 40, height: 40)
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: pulseScale
                        )

                    Circle()
                        .fill(Color.kompisSuccess)
                        .frame(width: 12, height: 12)

                    Text("LIVE")
                        .font(.system(size: 7, weight: .black))
                        .foregroundColor(.white)
                        .offset(y: 10)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(phaseText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.kompisTextPrimary)
                    if let eta = order.estimatedArrival {
                        Text("Ankommer om ca. \(eta) min")
                            .font(.system(size: 13))
                            .foregroundColor(.kompisTextSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.kompisTextSecondary)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .padding(Spacing.lg)
            .glassCard(cornerRadius: CornerRadius.xl)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear { pulseScale = 1.3 }
    }

    var phaseText: String {
        switch order.phase {
        case .searching: return "Finner en Kompis..."
        case .matched:   return "Kompis funnet!"
        case .enRoute:   return "Hjelp er på vei"
        case .arrived:   return "Kompisen er fremme"
        case .inProgress: return "Oppdraget pågår"
        case .completed: return "Fullført!"
        default: return ""
        }
    }
}

// MARK: - Nearby Task Row (glass-stil)

struct NearbyTaskRow: View {
    let task: Task

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Kategori-ikon med glass-bakgrunn
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.kompisAccent.opacity(0.2))
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )

                Image(systemName: task.category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(.kompisAccent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.kompisTextPrimary)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.kompisTextMuted)
                    Text(task.pickupLocation.city ?? "Oslo")
                    Text("·")
                    Text(String(format: "%.1f km", task.distance))
                }
                .font(.system(size: 12))
                .foregroundColor(.kompisTextSecondary)
            }

            Spacer()

            // Prismerke (glass)
            VStack(spacing: 2) {
                Text("\(task.price)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisSecondary)
                Text("kr")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.kompisTextMuted)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.kompisSecondary.opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(Color.kompisSecondary.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .padding(Spacing.md)
        .glassCard(cornerRadius: CornerRadius.lg)
    }
}

// MARK: - How It Works Row (glass-stil)

struct HowItWorksRow: View {
    let number: String
    var icon: String = ""
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            // Nummerert sirkel med gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.kompisAccent, Color.kompisPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 34, height: 34)

                Text(number)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.kompisTextPrimary)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.kompisTextSecondary)
            }

            Spacer()

            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.kompisAccent.opacity(0.7))
        }
    }
}
