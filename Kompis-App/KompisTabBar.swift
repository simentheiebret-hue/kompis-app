//
//  KompisTabBar.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

enum TabItem: Int, CaseIterable {
    case home, feed, create, activity, profile

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .feed: return "rectangle.grid.1x2.fill"
        case .create: return "plus"
        case .activity: return "clock.fill"
        case .profile: return "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home: return "Hjem"
        case .feed: return "Oppdrag"
        case .create: return ""
        case .activity: return "Aktivitet"
        case .profile: return "Profil"
        }
    }
}

struct KompisTabBar: View {
    @Binding var selectedTab: TabItem
    @Binding var showCreateTask: Bool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                if tab == .create {
                    // Floating Action Button – sentrert og løftet
                    Button(action: { showCreateTask = true }) {
                        ZStack {
                            // Ytre glød-ring
                            Circle()
                                .fill(Color.kompisPrimary.opacity(0.25))
                                .frame(width: 68, height: 68)
                                .blur(radius: 8)

                            // Hoved-sirkel med gradient
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.kompisSecondary, Color.kompisPrimary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                )
                                .shadow(color: Color.kompisPrimary.opacity(0.5), radius: 12, x: 0, y: 6)

                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -22)
                    .frame(maxWidth: .infinity)
                } else {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 5) {
                            ZStack {
                                // Aktiv indikator-pill
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.kompisAccent.opacity(0.2))
                                        .frame(width: 40, height: 32)
                                        .transition(.scale.combined(with: .opacity))
                                }

                                Image(systemName: tab.icon)
                                    .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                                    .foregroundColor(selectedTab == tab ? Color.kompisSecondary : Color.kompisTextMuted)
                                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                            }
                            .frame(width: 40, height: 32)

                            Text(tab.title)
                                .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? Color.kompisSecondary : Color.kompisTextMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                    }
                }
            }
        }
        .padding(.top, Spacing.md)
        .padding(.bottom, 28)
        .padding(.horizontal, Spacing.sm)
        .background(
            ZStack {
                // Frosted glass base
                Rectangle()
                    .fill(.ultraThinMaterial)

                // Subtil grønn toning over glasset
                Rectangle()
                    .fill(Color.kompisBgSecondary.opacity(0.6))

                // Top-border highlight
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                    Spacer()
                }
            }
        )
        .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: -8)
    }
}
