//
//  HomeView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(TaskService.self) var taskService
    @State private var showBookingFlow  = false
    @State private var bookingCategory: TaskCategory = .transport
    @State private var showActiveOrder  = false
    @State private var hasActiveOrder   = false

    let categories = TaskCategory.allCases

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.kompisBgPrimary.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // MARK: - Header
                        HomeHeader()

                        VStack(alignment: .leading, spacing: Spacing.xxl) {

                            // MARK: - Aktiv ordre-banner
                            if hasActiveOrder {
                                ActiveOrderBanner(order: MockData.mockActiveOrder) {
                                    showActiveOrder = true
                                }
                                .padding(.horizontal, Spacing.lg)
                            }

                            // MARK: - Kategorier
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                SectionLabel("Hva trenger du hjelp med?")
                                    .padding(.horizontal, Spacing.lg)

                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible(), spacing: Spacing.md),
                                        GridItem(.flexible(), spacing: Spacing.md),
                                        GridItem(.flexible(), spacing: Spacing.md)
                                    ],
                                    spacing: Spacing.md
                                ) {
                                    ForEach(categories, id: \.self) { category in
                                        QuickCategoryButton(category: category) {
                                            bookingCategory = category
                                            showBookingFlow = true
                                        }
                                    }
                                }
                                .padding(.horizontal, Spacing.lg)
                            }

                            // MARK: - Slik fungerer det
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                SectionLabel("Slik fungerer det")
                                    .padding(.horizontal, Spacing.lg)

                                VStack(spacing: 0) {
                                    ForEach(Array(howItWorksSteps.enumerated()), id: \.offset) { index, step in
                                        HowItWorksRow(step: step, stepNumber: index + 1)

                                        if index < howItWorksSteps.count - 1 {
                                            Rectangle()
                                                .fill(Color.kompisDivider)
                                                .frame(height: 1)
                                                .padding(.leading, 56)
                                        }
                                    }
                                }
                                .kompisCard(radius: CornerRadius.xl)
                                .padding(.horizontal, Spacing.lg)
                            }

                            // MARK: - I nærheten
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                HStack {
                                    SectionLabel("I nærheten")
                                    Spacer()
                                    Button { } label: {
                                        HStack(spacing: 4) {
                                            Text("Se alle")
                                            Image(systemName: "arrow.right")
                                        }
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.kompisPrimary)
                                    }
                                }
                                .padding(.horizontal, Spacing.lg)

                                if taskService.isLoading {
                                    ProgressView().tint(.kompisPrimary).padding()
                                } else if taskService.tasks.isEmpty {
                                    Text("Ingen oppdrag i nærheten enda")
                                        .font(.system(size: 14))
                                        .foregroundColor(.kompisTextMuted)
                                        .padding(.horizontal, Spacing.lg)
                                } else {
                                    VStack(spacing: Spacing.sm) {
                                        ForEach(taskService.tasks.prefix(5)) { task in
                                            NavigationLink(destination: TaskDetailView(task: task)) {
                                                NearbyTaskRow(task: task)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, Spacing.lg)
                                }
                            }

                            Spacer(minLength: 120)
                        }
                        .padding(.top, Spacing.xl)
                    }
                }
            }
            .navigationBarHidden(true)
            .task { taskService.hentOppdrag() }
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

    var howItWorksSteps: [(icon: String, title: String, description: String)] {
        [
            ("camera.fill",           "Ta et bilde",       "Vis hva du trenger hjelp med"),
            ("text.alignleft",        "Beskriv kort",      "Hva, hvor og når"),
            ("checkmark.circle.fill", "Hjelpen er på vei", "Følg med i sanntid"),
        ]
    }
}

// MARK: - Header (clean, ingen farget bakgrunn)

private struct HomeHeader: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        let name = authService.currentUser?.name ?? "deg"
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Hei, \(name) 👋")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                Text("Hva trenger du hjelp med?")
                    .font(.system(size: 15))
                    .foregroundColor(.kompisTextSecondary)
            }

            Spacer()

            // Avatar
            ZStack {
                Circle()
                    .fill(Color.kompisPrimary.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(String(name.prefix(1)))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisPrimary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }
}

// MARK: - Section Label

private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.kompisTextPrimary)
    }
}

// MARK: - Quick Category Button

struct QuickCategoryButton: View {
    let category: TaskCategory
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.kompisPrimary.opacity(0.09))
                        .frame(width: 62, height: 62)

                    Image(systemName: category.icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.kompisPrimary)
                }

                Text(category.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.kompisTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.kompisBgCard)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}

// MARK: - Active Order Banner (ingen animasjon)

struct ActiveOrderBanner: View {
    let order: ActiveOrder
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Statisk grønn dot – ingen puls-animasjon
                ZStack {
                    Circle()
                        .fill(Color.kompisSuccess.opacity(0.2))
                        .frame(width: 42, height: 42)
                    Circle()
                        .fill(Color.kompisSuccess)
                        .frame(width: 14, height: 14)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(phaseText)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    if let eta = order.estimatedArrival {
                        Text("Ankommer om ca. \(eta) min")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(Spacing.lg)
            .background(
                LinearGradient(
                    colors: [Color.kompisPrimary, Color(hex: "#3D7A62")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
            .kompisElevated()
        }
        .buttonStyle(PlainButtonStyle())
    }

    var phaseText: String {
        switch order.phase {
        case .searching:  return "Finner en Kompis..."
        case .matched:    return "Kompis funnet!"
        case .enRoute:    return "Hjelp er på vei"
        case .arrived:    return "Kompisen er fremme"
        case .inProgress: return "Oppdraget pågår"
        case .completed:  return "Fullført!"
        default:          return ""
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
                    .fill(Color.kompisPrimary.opacity(0.09))
                    .frame(width: 52, height: 52)

                Image(systemName: task.category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(.kompisPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.kompisTextPrimary)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11))
                        .foregroundColor(.kompisTextMuted)
                    Text(task.pickupLocation.city ?? "Oslo")
                        .foregroundColor(.kompisTextSecondary)
                    Text("·")
                        .foregroundColor(.kompisTextMuted)
                    Text(String(format: "%.1f km", task.distance))
                        .foregroundColor(.kompisTextSecondary)
                }
                .font(.system(size: 12))
            }

            Spacer()

            Text("\(task.price) kr")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.kompisPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.kompisPrimary.opacity(0.09))
                .clipShape(Capsule())
        }
        .padding(Spacing.md)
        .kompisCard(radius: CornerRadius.lg)
    }
}

// MARK: - How It Works Row

struct HowItWorksRow: View {
    let step: (icon: String, title: String, description: String)
    let stepNumber: Int

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.kompisPrimary, Color.kompisAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Text("\(stepNumber)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.kompisTextPrimary)
                Text(step.description)
                    .font(.system(size: 13))
                    .foregroundColor(.kompisTextSecondary)
            }

            Spacer()

            Image(systemName: step.icon)
                .font(.system(size: 18))
                .foregroundColor(.kompisAccent)
        }
        .padding(Spacing.lg)
    }
}
