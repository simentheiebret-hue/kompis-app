//
//  HomeView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI
import MapKit

// MARK: - Annotasjon for Task-pins på kartet

struct TaskAnnotation: Identifiable {
    let id: UUID
    let task: Task
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: task.pickupLocation.latitude,
            longitude: task.pickupLocation.longitude
        )
    }
}

// MARK: - HomeView

struct HomeView: View {
    @State private var showBookingFlow  = false
    @State private var bookingCategory: TaskCategory = .transport
    @State private var showActiveOrder  = false
    @State private var hasActiveOrder   = true
    @State private var selectedTask: Task? = nil

    // Oslo sentrum
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 59.9250, longitude: 10.7400),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )

    let categories = TaskCategory.allCases

    // Konverter tasks til annotasjoner
    var taskAnnotations: [TaskAnnotation] {
        MockData.tasks.map { TaskAnnotation(id: $0.id, task: $0) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                // MARK: - Kart (full skjerm i bakgrunn)
                Map(position: $cameraPosition) {
                    ForEach(taskAnnotations) { annotation in
                        Annotation("", coordinate: annotation.coordinate) {
                            TaskMapPin(task: annotation.task, isSelected: selectedTask?.id == annotation.task.id) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedTask = (selectedTask?.id == annotation.task.id) ? nil : annotation.task
                                }
                            }
                        }
                    }

                    // Brukerens posisjon (mock: Grünerløkka)
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: 59.9226, longitude: 10.7594)) {
                        UserLocationPin()
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea()

                // MARK: - Header overlay øverst på kartet
                MapHeaderOverlay(
                    userName: MockData.currentUser.name,
                    hasActiveOrder: hasActiveOrder,
                    order: MockData.mockActiveOrder,
                    onOrderTap: { showActiveOrder = true }
                )

                // MARK: - Bottom sheet panel
                VStack(spacing: 0) {
                    Spacer()

                    BottomSheetPanel(
                        categories: categories,
                        tasks: MockData.tasks,
                        selectedTask: $selectedTask,
                        onCategoryTap: { category in
                            bookingCategory = category
                            showBookingFlow = true
                        }
                    )
                }
                .ignoresSafeArea(edges: .bottom)
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

// MARK: - Kart: Task-pin

struct TaskMapPin: View {
    let task: Task
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.kompisPrimary : Color.kompisBgCard)
                        .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                        .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
                        .overlay(
                            Circle()
                                .stroke(Color.kompisPrimary, lineWidth: isSelected ? 0 : 2)
                        )

                    Image(systemName: task.category.icon)
                        .font(.system(size: isSelected ? 18 : 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .kompisPrimary)
                }

                // Pris-boble under pin
                if isSelected {
                    Text("\(task.price) kr")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.kompisPrimary)
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Kart: Brukerlokasjon-pin

struct UserLocationPin: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 36, height: 36)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .opacity(pulse ? 0 : 1)
                .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulse)

            Circle()
                .fill(Color.blue.opacity(0.25))
                .frame(width: 20, height: 20)

            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
                .shadow(color: .blue.opacity(0.4), radius: 4)

            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Kart-header overlay

struct MapHeaderOverlay: View {
    let userName: String
    let hasActiveOrder: Bool
    let order: ActiveOrder
    let onOrderTap: () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Topp-rad: navn + avatar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hei, \(userName)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("I nærheten av deg")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 42, height: 42)
                    Text(String(userName.prefix(1)))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1.5))
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)

            // Aktiv ordre – ingen puls-animasjon, bare statisk grønn dot
            if hasActiveOrder {
                Button(action: onOrderTap) {
                    HStack(spacing: Spacing.md) {
                        // Statisk live-dot (ingen animasjon)
                        ZStack {
                            Circle()
                                .fill(Color.kompisSuccess.opacity(0.25))
                                .frame(width: 32, height: 32)
                            Circle()
                                .fill(Color.kompisSuccess)
                                .frame(width: 11, height: 11)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(orderPhaseText(order.phase))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            if let eta = order.estimatedArrival {
                                Text("Ankommer om ca. \(eta) min")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .background(Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, Spacing.md)
        .background(
            LinearGradient(
                colors: [
                    Color.kompisPrimary.opacity(0.92),
                    Color.kompisPrimary.opacity(0.7),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea(edges: .top)
    }

    func orderPhaseText(_ phase: OrderPhase) -> String {
        switch phase {
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

// MARK: - Bottom Sheet Panel

struct BottomSheetPanel: View {
    let categories: [TaskCategory]
    let tasks: [Task]
    @Binding var selectedTask: Task?
    let onCategoryTap: (TaskCategory) -> Void

    // Panelet kan trekkes mellom to høyder
    @State private var panelOffset: CGFloat = 0
    private let collapsedPeek: CGFloat = 320  // hvor mye som stikker opp i "kompakt" modus

    var body: some View {
        VStack(spacing: 0) {
            // Drag-handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.kompisTextMuted.opacity(0.4))
                .frame(width: 36, height: 4)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {

                    // MARK: - Valgt task-detalj (fra kart-pin)
                    if let task = selectedTask {
                        SelectedTaskCard(task: task) {
                            withAnimation(.spring(response: 0.3)) { selectedTask = nil }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // MARK: - Kategorier
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        SectionLabel("Bestill hjelp")
                            .padding(.horizontal, Spacing.lg)

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: Spacing.sm),
                                GridItem(.flexible(), spacing: Spacing.sm),
                                GridItem(.flexible(), spacing: Spacing.sm),
                                GridItem(.flexible(), spacing: Spacing.sm),
                                GridItem(.flexible(), spacing: Spacing.sm)
                            ],
                            spacing: Spacing.sm
                        ) {
                            ForEach(categories, id: \.self) { category in
                                CompactCategoryButton(category: category) {
                                    onCategoryTap(category)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }

                    // MARK: - Oppdrag i nærheten (liste)
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            SectionLabel("I nærheten")
                            Spacer()
                            Text("\(tasks.count) oppdrag")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.kompisTextMuted)
                        }
                        .padding(.horizontal, Spacing.lg)

                        VStack(spacing: Spacing.sm) {
                            ForEach(tasks) { task in
                                NearbyTaskRow(task: task)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedTask = task
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.kompisBgPrimary
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: CornerRadius.xxl,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: CornerRadius.xxl
                    )
                )
        )
        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: -6)
        .frame(height: collapsedPeek)
    }
}

// MARK: - Valgt task-kort (fra kart)

struct SelectedTaskCard: View {
    let task: Task
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                KompisBadge(text: task.category.rawValue, variant: .category)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.kompisTextSecondary)
                        .padding(8)
                        .background(Color.kompisSurface)
                        .clipShape(Circle())
                }
            }

            Text(task.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.kompisTextPrimary)

            Text(task.description)
                .font(.system(size: 13))
                .foregroundColor(.kompisTextSecondary)
                .lineLimit(2)

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                    Text(task.pickupLocation.city ?? "Oslo")
                    Text("·")
                    Text(String(format: "%.1f km", task.distance))
                }
                .font(.system(size: 12))
                .foregroundColor(.kompisTextSecondary)

                Spacer()

                Text("\(task.price) kr")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisPrimary)
            }

            KompisButton(title: "Jeg vil hjelpe!", style: .primary) {}
        }
        .padding(Spacing.lg)
        .kompisCard(radius: CornerRadius.xl)
    }
}

// MARK: - Kompakt kategori-knapp (5 i rad)

struct CompactCategoryButton: View {
    let category: TaskCategory
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.kompisPrimary.opacity(0.09))
                        .frame(width: 48, height: 48)

                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.kompisPrimary)
                }

                Text(category.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.kompisTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.92 : 1.0)
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

// MARK: - Nearby Task Row (beholdt fra forrige versjon)

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

// MARK: - Active Order Banner (beholdt for andre views som bruker den)

struct ActiveOrderBanner: View {
    let order: ActiveOrder
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
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

// MARK: - How It Works Row (beholdt for andre views)

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
