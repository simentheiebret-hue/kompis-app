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
                    // Floating Action Button
                    Button(action: { showCreateTask = true }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.kompisPrimary, .kompisAccent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(color: .kompisPrimary.opacity(0.4), radius: 8, x: 0, y: 4)

                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -20)
                    .frame(maxWidth: .infinity)
                } else {
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 22))
                            Text(tab.title)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(selectedTab == tab ? .kompisPrimary : .kompisTextMuted)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.xl)
        .background(
            Color.kompisBgCard
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: -5)
        )
    }
}
