//
//  ActiveOrderView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct ActiveOrderView: View {
    let order: ActiveOrder
    let onDismiss: () -> Void

    @State private var showChat = false
    @State private var messageText = ""
    @State private var simulatedPhase: OrderPhase

    init(order: ActiveOrder, onDismiss: @escaping () -> Void) {
        self.order = order
        self.onDismiss = onDismiss
        _simulatedPhase = State(initialValue: order.phase)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color.kompisBgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Top bar
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.kompisTextPrimary)
                            .padding(Spacing.md)
                            .background(Color.kompisBgSecondary)
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Status pill
                    HStack(spacing: Spacing.sm) {
                        Circle()
                            .fill(phaseColor)
                            .frame(width: 8, height: 8)
                        Text(phaseText)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(phaseColor)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(phaseColor.opacity(0.12))
                    .cornerRadius(CornerRadius.pill)

                    Spacer()

                    // Demo: Trykk for å simulere neste fase
                    Button(action: advancePhase) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.kompisTextMuted)
                            .padding(Spacing.md)
                            .background(Color.kompisBgSecondary)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

                // MARK: - Kart-placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .fill(Color.kompisBgSecondary)
                        .frame(height: 220)

                    VStack(spacing: Spacing.md) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.kompisTextMuted)

                        if simulatedPhase == .searching {
                            // Søke-animasjon
                            VStack(spacing: Spacing.sm) {
                                ProgressView()
                                    .tint(.kompisPrimary)
                                Text("Leter etter en Kompis i nærheten...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.kompisTextSecondary)
                            }
                        } else if let eta = order.estimatedArrival, simulatedPhase == .enRoute {
                            Text("Ankommer om ~\(eta) min")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.kompisPrimary)
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

                // MARK: - Hoved-status banner
                StatusBanner(phase: simulatedPhase)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)

                // MARK: - Kompis-info (etter matching)
                if simulatedPhase != .searching && simulatedPhase != .idle {
                    if let helper = order.assignedHelper {
                        HelperInfoCard(helper: helper, onChat: {
                            withAnimation(.spring(response: 0.3)) {
                                showChat.toggle()
                            }
                        })
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                // MARK: - Oppdrags-detaljer
                OrderDetailsCard(order: order)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)

                Spacer()

                // MARK: - Fullført-knapp (vises ved completed)
                if simulatedPhase == .completed {
                    VStack(spacing: Spacing.md) {
                        KompisButton(title: "Vurder din Kompis", style: .primary, icon: "star.fill") {
                            // Åpne rating
                        }
                    }
                    .padding(Spacing.lg)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // MARK: - Chat overlay
            if showChat {
                ChatOverlay(
                    messages: order.messages,
                    helperName: order.assignedHelper?.name ?? "Kompis",
                    messageText: $messageText,
                    onClose: { showChat = false }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.4), value: simulatedPhase)
        .animation(.spring(response: 0.3), value: showChat)
    }

    // MARK: - Phase helpers

    var phaseText: String {
        switch simulatedPhase {
        case .idle: return "Klar"
        case .searching: return "Søker..."
        case .matched: return "Matchet!"
        case .enRoute: return "På vei"
        case .arrived: return "Er fremme"
        case .inProgress: return "Pågår"
        case .completed: return "Fullført"
        case .rated: return "Vurdert"
        }
    }

    var phaseColor: Color {
        switch simulatedPhase {
        case .searching: return .kompisSecondary
        case .matched: return .kompisPrimary
        case .enRoute: return .kompisSuccess
        case .arrived: return .kompisPrimary
        case .inProgress: return .kompisSecondary
        case .completed: return .kompisSuccess
        default: return .kompisTextMuted
        }
    }

    func advancePhase() {
        withAnimation(.spring(response: 0.4)) {
            switch simulatedPhase {
            case .idle: simulatedPhase = .searching
            case .searching: simulatedPhase = .matched
            case .matched: simulatedPhase = .enRoute
            case .enRoute: simulatedPhase = .arrived
            case .arrived: simulatedPhase = .inProgress
            case .inProgress: simulatedPhase = .completed
            case .completed: simulatedPhase = .rated
            case .rated: onDismiss()
            }
        }
    }
}

// MARK: - Status Banner

struct StatusBanner: View {
    let phase: OrderPhase

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Animert ikon
            ZStack {
                Circle()
                    .fill(bannerColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: bannerIcon)
                    .font(.system(size: 22))
                    .foregroundColor(bannerColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(bannerTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                Text(bannerSubtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.kompisTextSecondary)
            }

            Spacer()
        }
        .padding(Spacing.lg)
        .background(bannerColor.opacity(0.08))
        .cornerRadius(CornerRadius.lg)
    }

    var bannerColor: Color {
        switch phase {
        case .searching: return .kompisSecondary
        case .matched: return .kompisPrimary
        case .enRoute: return .kompisSuccess
        case .arrived: return .kompisPrimary
        case .inProgress: return .kompisSecondary
        case .completed: return .kompisSuccess
        default: return .kompisTextMuted
        }
    }

    var bannerIcon: String {
        switch phase {
        case .searching: return "magnifyingglass"
        case .matched: return "person.crop.circle.badge.checkmark"
        case .enRoute: return "car.fill"
        case .arrived: return "mappin.and.ellipse"
        case .inProgress: return "wrench.and.screwdriver.fill"
        case .completed: return "checkmark.circle.fill"
        default: return "circle"
        }
    }

    var bannerTitle: String {
        switch phase {
        case .searching: return "Finner en Kompis..."
        case .matched: return "Kompis funnet!"
        case .enRoute: return "Hjelp er på vei"
        case .arrived: return "Kompisen er fremme"
        case .inProgress: return "Oppdraget pågår"
        case .completed: return "Fullført!"
        default: return ""
        }
    }

    var bannerSubtitle: String {
        switch phase {
        case .searching: return "Vi leter etter noen i nærheten"
        case .matched: return "Din Kompis har akseptert oppdraget"
        case .enRoute: return "Følg med på kartet"
        case .arrived: return "Gå ut og møt din Kompis"
        case .inProgress: return "Jobben er i gang"
        case .completed: return "Takk for at du brukte Kompis!"
        default: return ""
        }
    }
}

// MARK: - Helper Info Card

struct HelperInfoCard: View {
    let helper: User
    let onChat: () -> Void

    var body: some View {
        KompisCard {
            HStack(spacing: Spacing.md) {
                // Avatar
                Circle()
                    .fill(Color.kompisPrimary.opacity(0.15))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(String(helper.name.prefix(1)))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.kompisPrimary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Spacing.xs) {
                        Text(helper.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.kompisTextPrimary)
                        if helper.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.kompisPrimary)
                        }
                    }

                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        Text(String(format: "%.1f", helper.rating))
                            .font(.system(size: 13, weight: .medium))
                        Text("·")
                        Text("\(helper.completedTasks) oppdrag")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.kompisTextSecondary)

                    if let vehicle = helper.vehicleDescription {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 11))
                            Text(vehicle)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.kompisAccent)
                    }
                }

                Spacer()

                // Chat-knapp
                Button(action: onChat) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.kompisPrimary)
                        .clipShape(Circle())
                }

                // Ring-knapp
                Button(action: {}) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.kompisPrimary)
                        .frame(width: 44, height: 44)
                        .background(Color.kompisPrimary.opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
    }
}

// MARK: - Order Details Card

struct OrderDetailsCard: View {
    let order: ActiveOrder

    var body: some View {
        KompisCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Oppdragstittel
                HStack {
                    Image(systemName: order.task.category.icon)
                        .foregroundColor(.kompisAccent)
                    Text(order.task.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.kompisTextPrimary)
                    Spacer()
                    Text("\(order.task.price) kr")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisPrimary)
                }

                Divider()

                // Fra/Til
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.sm) {
                        Circle()
                            .fill(Color.kompisSuccess)
                            .frame(width: 8, height: 8)
                        Text(order.task.pickupLocation.address)
                            .font(.system(size: 13))
                            .foregroundColor(.kompisTextSecondary)
                            .lineLimit(1)
                    }

                    if let delivery = order.task.deliveryLocation {
                        HStack(spacing: Spacing.sm) {
                            Circle()
                                .fill(Color.kompisSecondary)
                                .frame(width: 8, height: 8)
                            Text(delivery.address)
                                .font(.system(size: 13))
                                .foregroundColor(.kompisTextSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Chat Overlay (kontekstuell real-time chat)

struct ChatOverlay: View {
    let messages: [ChatMessage]
    let helperName: String
    @Binding var messageText: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.kompisTextMuted)
                .frame(width: 40, height: 4)
                .padding(.top, Spacing.md)

            // Header
            HStack {
                Text("Chat med \(helperName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.kompisTextPrimary)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.kompisTextSecondary)
                        .padding(Spacing.sm)
                        .background(Color.kompisBgSecondary)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.sm)

            Divider()

            // Meldinger
            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(messages) { msg in
                        let isMe = msg.senderName == MockData.currentUser.name
                        HStack {
                            if isMe { Spacer() }

                            Text(msg.content)
                                .font(.system(size: 15))
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.md)
                                .background(isMe ? Color.kompisPrimary : Color.kompisBgSecondary)
                                .foregroundColor(isMe ? .white : .kompisTextPrimary)
                                .cornerRadius(CornerRadius.lg)

                            if !isMe { Spacer() }
                        }
                    }
                }
                .padding(Spacing.lg)
            }

            Divider()

            // Input
            HStack(spacing: Spacing.md) {
                TextField("Skriv en melding...", text: $messageText)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .background(Color.kompisBgSecondary)
                    .cornerRadius(CornerRadius.pill)

                Button(action: {}) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.kompisPrimary)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .background(Color.kompisBgCard)
        .cornerRadius(CornerRadius.xl, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.15), radius: 20, y: -5)
        .frame(maxHeight: 420)
    }
}
