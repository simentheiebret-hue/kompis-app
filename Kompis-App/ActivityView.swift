//
//  ActivityView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct ActivityView: View {
    @State private var selectedSegment = 0
    let activeOrder = MockData.mockActiveOrder
    let completedOrders = MockData.completedOrders

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Aktivitet")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisTextPrimary)

                    // Segment picker
                    Picker("", selection: $selectedSegment) {
                        Text("Aktive").tag(0)
                        Text("Fullførte").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.md)

                ScrollView {
                    VStack(spacing: Spacing.md) {
                        if selectedSegment == 0 {
                            // MARK: - Aktive oppdrag
                            ActiveOrderActivityCard(order: activeOrder)

                        } else {
                            // MARK: - Fullførte oppdrag
                            ForEach(completedOrders) { order in
                                CompletedOrderCard(order: order)
                            }

                            if completedOrders.isEmpty {
                                EmptyStateView()
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)

                    Spacer(minLength: 120)
                }
            }
            .background(Color.kompisBgPrimary)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Active Order Activity Card

struct ActiveOrderActivityCard: View {
    let order: ActiveOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status header
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.kompisSuccess.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Circle()
                        .fill(Color.kompisSuccess)
                        .frame(width: 10, height: 10)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(phaseText(order.phase))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.kompisTextPrimary)
                    if let eta = order.estimatedArrival {
                        Text("Ankommer om ~\(eta) min")
                            .font(.system(size: 13))
                            .foregroundColor(.kompisSuccess)
                    }
                }

                Spacer()

                KompisBadge(text: order.task.category.rawValue, variant: .category)
            }
            .padding(Spacing.lg)

            Divider()
                .padding(.horizontal, Spacing.lg)

            // Oppdragsinfo
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text(order.task.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.kompisTextPrimary)

                // Lokasjon
                HStack(spacing: Spacing.sm) {
                    Circle()
                        .fill(Color.kompisSuccess)
                        .frame(width: 6, height: 6)
                    Text(order.task.pickupLocation.address)
                        .font(.system(size: 13))
                        .foregroundColor(.kompisTextSecondary)
                        .lineLimit(1)
                }

                if let delivery = order.task.deliveryLocation {
                    HStack(spacing: Spacing.sm) {
                        Circle()
                            .fill(Color.kompisSecondary)
                            .frame(width: 6, height: 6)
                        Text(delivery.address)
                            .font(.system(size: 13))
                            .foregroundColor(.kompisTextSecondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(Spacing.lg)

            // Kompis-info
            if let helper = order.assignedHelper {
                Divider()
                    .padding(.horizontal, Spacing.lg)

                HStack(spacing: Spacing.md) {
                    Circle()
                        .fill(Color.kompisPrimary.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(String(helper.name.prefix(1)))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.kompisPrimary)
                        )

                    VStack(alignment: .leading, spacing: 1) {
                        Text(helper.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.kompisTextPrimary)
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", helper.rating))
                                .font(.system(size: 12))
                                .foregroundColor(.kompisTextSecondary)
                        }
                    }

                    Spacer()

                    Text("\(order.task.price) kr")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisPrimary)
                }
                .padding(Spacing.lg)
            }

            // Siste melding (kontekstuell chat-preview)
            if let lastMessage = order.messages.last {
                Divider()
                    .padding(.horizontal, Spacing.lg)

                HStack(spacing: Spacing.md) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.kompisAccent)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(lastMessage.senderName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.kompisTextSecondary)
                        Text(lastMessage.content)
                            .font(.system(size: 14))
                            .foregroundColor(.kompisTextPrimary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.kompisTextMuted)
                }
                .padding(Spacing.lg)
            }
        }
        .background(Color.kompisBgCard)
        .cornerRadius(CornerRadius.lg)
        .kompisShadow()
    }

    func phaseText(_ phase: OrderPhase) -> String {
        switch phase {
        case .searching: return "Finner en Kompis..."
        case .matched: return "Kompis funnet!"
        case .enRoute: return "Hjelp er på vei"
        case .arrived: return "Kompisen er fremme"
        case .inProgress: return "Oppdraget pågår"
        case .completed: return "Fullført"
        default: return ""
        }
    }
}

// MARK: - Completed Order Card

struct CompletedOrderCard: View {
    let order: ActiveOrder

    var body: some View {
        KompisCard {
            HStack(spacing: Spacing.md) {
                // Ikon
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(Color.kompisSuccess.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.kompisSuccess)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(order.task.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.kompisTextPrimary)
                        .lineLimit(1)

                    HStack(spacing: Spacing.sm) {
                        if let helper = order.assignedHelper {
                            Text(helper.name)
                        }
                        Text("·")
                        Text(order.task.category.rawValue)
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.kompisTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(order.task.price) kr")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisTextPrimary)
                    Text(formatDate(order.startedAt))
                        .font(.system(size: 12))
                        .foregroundColor(.kompisTextMuted)
                }
            }
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMM"
        formatter.locale = Locale(identifier: "nb_NO")
        return formatter.string(from: date)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.kompisTextMuted)

            Text("Ingen fullførte oppdrag ennå")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.kompisTextSecondary)

            Text("Dine fullførte oppdrag vil vises her")
                .font(.system(size: 14))
                .foregroundColor(.kompisTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxxl)
    }
}
