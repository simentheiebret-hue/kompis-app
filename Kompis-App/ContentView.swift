//
//  ContentView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .home
    @State private var showCategoryPicker = false
    @State private var showBookingFlow = false
    @State private var selectedCategory: TaskCategory = .transport

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .feed:
                    FeedView()
                case .create:
                    EmptyView()
                case .map:
                    MapView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            KompisTabBar(selectedTab: $selectedTab, showCreateTask: $showCategoryPicker)
        }
        .background(Color.kompisBgPrimary)
        .ignoresSafeArea(edges: .bottom)
        // Steg 1: velg kategori
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerSheet(
                onSelect: { category in
                    selectedCategory = category
                    showCategoryPicker = false
                    // Kort delay så sheet rekker å lukke seg
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showBookingFlow = true
                    }
                },
                onDismiss: {
                    showCategoryPicker = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        // Steg 2: bestillings-flow
        .fullScreenCover(isPresented: $showBookingFlow) {
            BookingFlowView(category: selectedCategory) {}
        }
    }
}

// MARK: - Kategorivelger-sheet

struct CategoryPickerSheet: View {
    let onSelect: (TaskCategory) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Handle + header
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Hva trenger du hjelp med?")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                Text("Velg en kategori for å starte")
                    .font(.system(size: 15))
                    .foregroundColor(.kompisTextSecondary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.lg)

            // Kategori-liste
            VStack(spacing: Spacing.sm) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    CategoryPickerRow(category: category) {
                        onSelect(category)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)

            Spacer()
        }
        .background(Color.kompisBgPrimary)
    }
}

// MARK: - Rad i kategorivelgeren

struct CategoryPickerRow: View {
    let category: TaskCategory
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                // Ikon-boks
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(Color.kompisPrimary.opacity(0.09))
                        .frame(width: 52, height: 52)
                    Image(systemName: category.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.kompisPrimary)
                }

                // Tekst
                VStack(alignment: .leading, spacing: 3) {
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.kompisTextPrimary)
                    Text(category.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.kompisTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.kompisTextMuted)
            }
            .padding(Spacing.md)
            .background(Color.kompisBgCard)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}

#Preview {
    ContentView()
}
