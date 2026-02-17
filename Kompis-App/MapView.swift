//
//  MapView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI
import MapKit

// MARK: - Task Map Annotation

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

// MARK: - MapView

struct MapView: View {
    @State private var selectedTask: Task? = nil
    @State private var searchText = ""
    @State private var selectedFilter: TaskCategory? = nil
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 59.9250, longitude: 10.7400),
            span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075)
        )
    )

    var filteredTasks: [Task] {
        MockData.tasks.filter { task in
            let matchesFilter = selectedFilter == nil || task.category == selectedFilter
            let matchesSearch = searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    var taskAnnotations: [TaskAnnotation] {
        filteredTasks.map { TaskAnnotation(id: $0.id, task: $0) }
    }

    var body: some View {
        ZStack(alignment: .top) {

            // MARK: - Kart
            Map(position: $cameraPosition) {
                ForEach(taskAnnotations) { annotation in
                    Annotation("", coordinate: annotation.coordinate) {
                        TaskMapPin(
                            task: annotation.task,
                            isSelected: selectedTask?.id == annotation.task.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTask = (selectedTask?.id == annotation.task.id)
                                    ? nil : annotation.task
                            }
                        }
                    }
                }

                // Brukerposisjon (mock)
                Annotation("", coordinate: CLLocationCoordinate2D(
                    latitude: 59.9226, longitude: 10.7594)
                ) {
                    UserLocationPin()
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()

            // MARK: - Søk + filtre overlay (toppen)
            VStack(spacing: Spacing.sm) {
                // Søkefelt
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.kompisTextMuted)

                    TextField("Søk etter oppdrag...", text: $searchText)
                        .font(.system(size: 15))
                        .foregroundColor(.kompisTextPrimary)

                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.kompisTextMuted)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.md)
                .background(Color.kompisBgCard)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)

                // Kategorifilter-piller
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        FilterPill(
                            label: "Alle",
                            icon: "square.grid.2x2.fill",
                            isActive: selectedFilter == nil
                        ) {
                            withAnimation(.spring(response: 0.3)) { selectedFilter = nil }
                        }

                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            FilterPill(
                                label: category.rawValue,
                                icon: category.icon,
                                isActive: selectedFilter == category
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedFilter = (selectedFilter == category) ? nil : category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)

            // MARK: - Valgt task-kort (bunnen)
            if let task = selectedTask {
                VStack {
                    Spacer()
                    MapTaskDetailCard(task: task) {
                        withAnimation(.spring(response: 0.3)) { selectedTask = nil }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, 100) // over tab-baren
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // MARK: - Teller (øvre høyre)
            VStack {
                HStack {
                    Spacer()
                    Text("\(filteredTasks.count) oppdrag")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.kompisTextPrimary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.kompisBgCard)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, 120) // under søkefeltet
                Spacer()
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedTask?.id)
    }
}

// MARK: - Task Map Pin

struct TaskMapPin: View {
    let task: Task
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                ZStack {
                    // Skyggesirkel
                    Circle()
                        .fill(Color.black.opacity(0.08))
                        .frame(
                            width: isSelected ? 52 : 42,
                            height: isSelected ? 52 : 42
                        )
                        .offset(y: 2)
                        .blur(radius: 3)

                    Circle()
                        .fill(isSelected ? Color.kompisPrimary : Color.kompisBgCard)
                        .frame(
                            width: isSelected ? 48 : 38,
                            height: isSelected ? 48 : 38
                        )
                        .overlay(
                            Circle().stroke(
                                isSelected ? Color.clear : Color.kompisPrimary,
                                lineWidth: 2
                            )
                        )
                        .shadow(
                            color: Color.kompisPrimary.opacity(isSelected ? 0.4 : 0.15),
                            radius: isSelected ? 10 : 5,
                            x: 0, y: 3
                        )

                    Image(systemName: task.category.icon)
                        .font(.system(size: isSelected ? 20 : 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .kompisPrimary)
                }

                // Pris-tag under pin
                if isSelected {
                    Text("\(task.price) kr")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.kompisPrimary)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bruker lokasjon pin

struct UserLocationPin: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 38, height: 38)
                .scaleEffect(pulse ? 1.5 : 1.0)
                .opacity(pulse ? 0 : 1)
                .animation(
                    .easeOut(duration: 1.6).repeatForever(autoreverses: false),
                    value: pulse
                )

            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 22, height: 22)

            Circle()
                .fill(Color.white)
                .frame(width: 15, height: 15)
                .shadow(color: .blue.opacity(0.5), radius: 4)

            Circle()
                .fill(Color.blue)
                .frame(width: 11, height: 11)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Filterchip

struct FilterPill: View {
    let label: String
    let icon: String
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isActive ? .white : .kompisTextPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isActive ? Color.kompisPrimary : Color.kompisBgCard)
            .clipShape(Capsule())
            .shadow(
                color: isActive
                    ? Color.kompisPrimary.opacity(0.3)
                    : Color.black.opacity(0.07),
                radius: 6, x: 0, y: 3
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Task-kort som vises fra kart

struct MapTaskDetailCard: View {
    let task: Task
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {

            // Topp-rad
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    KompisBadge(text: task.category.rawValue, variant: .category)
                    Text(task.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.kompisTextPrimary)
                }

                Spacer()

                // Lukk
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.kompisTextSecondary)
                        .padding(8)
                        .background(Color.kompisSurface)
                        .clipShape(Circle())
                }
            }

            // Beskrivelse
            Text(task.description)
                .font(.system(size: 13))
                .foregroundColor(.kompisTextSecondary)
                .lineLimit(2)

            // Adresse + avstand
            HStack(spacing: Spacing.xs) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 12))
                    .foregroundColor(.kompisTextMuted)
                Text(task.pickupLocation.address)
                    .lineLimit(1)
                Spacer()
                Text(String(format: "%.1f km", task.distance))
            }
            .font(.system(size: 12))
            .foregroundColor(.kompisTextSecondary)

            // Pris + knapp
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pris")
                        .font(.system(size: 11))
                        .foregroundColor(.kompisTextMuted)
                    Text("\(task.price) kr")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisPrimary)
                }

                Spacer()

                KompisButton(title: "Jeg vil hjelpe!", style: .primary, action: {})
                    .frame(maxWidth: 170)
            }
        }
        .padding(Spacing.lg)
        .kompisCard(radius: CornerRadius.xl)
    }
}
