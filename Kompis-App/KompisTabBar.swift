//
//  KompisTabBar.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

enum TabItem: Int, CaseIterable {
    case home, feed, create, map, profile

    var icon: String {
        switch self {
        case .home:    return "house.fill"
        case .feed:    return "rectangle.grid.1x2.fill"
        case .create:  return "plus"
        case .map:     return "map.fill"
        case .profile: return "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home:    return "Hjem"
        case .feed:    return "Oppdrag"
        case .create:  return ""
        case .map:     return "Kart"
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
                    // Senter-FAB
                    Button(action: { showCreateTask = true }) {
                        ZStack {
                            // Ytre glød
                            Circle()
                                .fill(Color.kompisPrimary.opacity(0.18))
                                .frame(width: 66, height: 66)
                                .blur(radius: 6)

                            // Hoved-sirkel
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.kompisPrimary, Color.kompisAccent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 54, height: 54)
                                .shadow(color: Color.kompisPrimary.opacity(0.35),
                                        radius: 10, x: 0, y: 5)

                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -18)
                    .frame(maxWidth: .infinity)

                } else {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 5) {
                            ZStack {
                                // Aktiv bakgrunnspill
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.kompisPrimary.opacity(0.1))
                                        .frame(width: 44, height: 30)
                                        .transition(.scale.combined(with: .opacity))
                                }

                                Image(systemName: tab.icon)
                                    .font(.system(
                                        size: 20,
                                        weight: selectedTab == tab ? .semibold : .regular
                                    ))
                                    .foregroundColor(
                                        selectedTab == tab
                                        ? .kompisPrimary
                                        : .kompisTextMuted
                                    )
                                    .scaleEffect(selectedTab == tab ? 1.08 : 1.0)
                                    .animation(
                                        .spring(response: 0.3, dampingFraction: 0.7),
                                        value: selectedTab
                                    )
                            }
                            .frame(width: 44, height: 30)

                            Text(tab.title)
                                .font(.system(
                                    size: 10,
                                    weight: selectedTab == tab ? .semibold : .regular
                                ))
                                .foregroundColor(
                                    selectedTab == tab
                                    ? .kompisPrimary
                                    : .kompisTextMuted
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.top, Spacing.md)
        .padding(.bottom, 28)
        .padding(.horizontal, Spacing.sm)
        .background(
            Color.kompisBgCard
                .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: -4)
        )
    }
}
