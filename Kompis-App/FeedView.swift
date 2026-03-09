//
//  FeedView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct FeedView: View {
    @Environment(TaskService.self) var taskService
    @State private var selectedFilter: FeedFilter = .all

    var feedItems: [FeedItem] {
        taskService.tasks.map { task in
            FeedItem(id: task.id, type: .needsHelp, task: task,
                     postedAgo: timeAgo(task.createdAt))
        }
    }

    var filteredItems: [FeedItem] {
        switch selectedFilter {
        case .all: return feedItems
        case .needsHelp: return feedItems.filter { $0.type == .needsHelp }
        case .freeItems: return feedItems.filter { $0.type == .freeItem }
        }
    }

    func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 { return "\(max(1, Int(interval / 60))) min" }
        else if interval < 86400 { return "\(Int(interval / 3600)) t" }
        else { return "\(Int(interval / 86400)) d" }
    }

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Oppdrag")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisTextPrimary)

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

                // Grid
                ScrollView {
                    if taskService.isLoading {
                        ProgressView()
                            .tint(.kompisPrimary)
                            .padding(.top, Spacing.xxl)
                    } else if filteredItems.isEmpty {
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundColor(.kompisTextMuted)
                            Text("Ingen oppdrag å vise")
                                .font(.system(size: 15))
                                .foregroundColor(.kompisTextMuted)
                        }
                        .padding(.top, Spacing.xxl)
                    } else {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(filteredItems) { item in
                                NavigationLink(destination: TaskDetailView(task: item.task)) {
                                    GridCard(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                    }

                    Spacer(minLength: 120)
                }
                .refreshable { await taskService.refreshOppdrag() }
                .background(Color.kompisBgPrimary)
            }
            .background(Color.kompisBgPrimary)
            .navigationBarHidden(true)
            .task { taskService.hentOppdrag() }
        }
    }
}

// MARK: - Grid Card

struct GridCard: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image area
            ZStack(alignment: .bottomLeading) {
                if let imageURL = item.task.images.first {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            categoryPlaceholder
                        }
                    }
                } else {
                    categoryPlaceholder
                }

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Price badge bottom-left
                Text(item.task.price == 0 ? "Gratis" : "\(item.task.price) kr")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.task.price == 0 ? Color.kompisSuccess : Color.kompisPrimary)
                    .cornerRadius(CornerRadius.md)
                    .padding(8)
            }
            .frame(height: 160)
            .clipped()
            .cornerRadius(CornerRadius.lg, corners: [.topLeft, .topRight])

            // Info area
            VStack(alignment: .leading, spacing: 4) {
                Text(item.task.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 11))
                        .foregroundColor(.kompisTextMuted)
                    Text(item.task.pickupLocation.city ?? "Oslo")
                        .font(.system(size: 12))
                        .foregroundColor(.kompisTextMuted)
                    Spacer()
                    Text(item.postedAgo)
                        .font(.system(size: 11))
                        .foregroundColor(.kompisTextMuted)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color.kompisBgCard)
        .cornerRadius(CornerRadius.lg)
        .kompisShadow()
    }

    private var categoryPlaceholder: some View {
        Rectangle()
            .fill(Color.kompisBgSecondary)
            .overlay(
                Image(systemName: item.task.category.icon)
                    .font(.system(size: 36))
                    .foregroundColor(.kompisTextMuted.opacity(0.5))
            )
    }
}

// MARK: - Feed Filter

enum FeedFilter: String, CaseIterable {
    case all = "Alle"
    case needsHelp = "Trenger hjelp"
    case freeItems = "Gis bort"

    var icon: String {
        switch self {
        case .all: return "rectangle.grid.2x2"
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
