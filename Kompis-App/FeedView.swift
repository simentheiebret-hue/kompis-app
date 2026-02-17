//
//  FeedView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct FeedView: View {
    @State private var selectedFilter: FeedFilter = .all
    let feedItems = MockData.feedItems

    var filteredItems: [FeedItem] {
        switch selectedFilter {
        case .all: return feedItems
        case .needsHelp: return feedItems.filter { $0.type == .needsHelp }
        case .freeItems: return feedItems.filter { $0.type == .freeItem }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Oppdrag")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisTextPrimary)

                    Text("Se hva som skjer i nabolaget")
                        .font(.system(size: 15))
                        .foregroundColor(.kompisTextSecondary)

                    // Filter pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            ForEach(FeedFilter.allCases, id: \.self) { filter in
                                FeedFilterPill(
                                    filter: filter,
                                    isSelected: selectedFilter == filter
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedFilter = filter
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.md)
                .background(Color.kompisBgPrimary)

                // Feed
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: TaskDetailView(task: item.task)) {
                                FeedCard(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)

                    Spacer(minLength: 120)
                }
                .background(Color.kompisBgPrimary)
            }
            .background(Color.kompisBgPrimary)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Feed Filter

enum FeedFilter: String, CaseIterable {
    case all = "Alle"
    case needsHelp = "Trenger hjelp"
    case freeItems = "Gis bort"

    var icon: String {
        switch self {
        case .all: return "rectangle.grid.1x2"
        case .needsHelp: return "hand.raised.fill"
        case .freeItems: return "gift.fill"
        }
    }
}

struct FeedFilterPill: View {
    let filter: FeedFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: filter.icon)
                    .font(.system(size: 12))
                Text(filter.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(isSelected ? Color.kompisPrimary : Color.kompisBgSecondary)
            .foregroundColor(isSelected ? .white : .kompisTextSecondary)
            .cornerRadius(CornerRadius.pill)
        }
    }
}

// MARK: - Feed Card

struct FeedCard: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Bilde/ikon area
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.kompisBgSecondary)
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: item.task.category.icon)
                            .font(.system(size: 44))
                            .foregroundColor(.kompisTextMuted.opacity(0.6))
                    )

                // Type badge
                HStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(typeBadgeColor)
                        .frame(width: 8, height: 8)
                    Text(typeBadgeText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(typeBadgeColor)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.kompisBgCard.opacity(0.95))
                .cornerRadius(CornerRadius.pill)
                .padding(Spacing.md)
            }
            .cornerRadius(CornerRadius.lg, corners: [.topLeft, .topRight])

            // Innhold
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(item.task.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                    .lineLimit(2)

                Text(item.task.description)
                    .font(.system(size: 14))
                    .foregroundColor(.kompisTextSecondary)
                    .lineLimit(2)

                HStack {
                    // Lokasjon
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                        Text(item.task.pickupLocation.city ?? "Oslo")
                        Text("·")
                        Text(String(format: "%.1f km", item.task.distance))
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.kompisTextMuted)

                    Spacer()

                    // Pris / Gratis
                    if item.type == .freeItem {
                        Text("Gratis")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.kompisSuccess)
                    } else {
                        Text("\(item.task.price) kr")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.kompisPrimary)
                    }
                }

                // Footer
                HStack(spacing: Spacing.sm) {
                    // Bruker
                    Circle()
                        .fill(Color.kompisBgSecondary)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(String(item.task.createdBy.name.prefix(1)))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.kompisTextSecondary)
                        )
                    Text(item.task.createdBy.name)
                        .font(.system(size: 13))
                        .foregroundColor(.kompisTextSecondary)

                    Spacer()

                    Text(item.postedAgo)
                        .font(.system(size: 12))
                        .foregroundColor(.kompisTextMuted)
                }
            }
            .padding(Spacing.md)
        }
        .background(Color.kompisBgCard)
        .cornerRadius(CornerRadius.lg)
        .kompisShadow()
    }

    var typeBadgeText: String {
        switch item.type {
        case .needsHelp: return "Trenger hjelp"
        case .freeItem: return "Gis bort"
        }
    }

    var typeBadgeColor: Color {
        switch item.type {
        case .needsHelp: return .kompisSecondary
        case .freeItem: return .kompisSuccess
        }
    }
}
