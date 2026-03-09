//
//  BookingFlowView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 07/02/2026.
//

import SwiftUI

struct BookingFlowView: View {
    let category: TaskCategory
    let onComplete: () -> Void

    @EnvironmentObject var authService: AuthService
    @Environment(TaskService.self) var taskService
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: BookingStep = .photo
    @State private var isSaving = false
    @State private var visError = false
    @State private var feilmelding: String? = nil
    @State private var description = ""
    @State private var pickupAddress = ""
    @State private var selectedVehicle: VehicleType? = nil
    @State private var price = ""
    @State private var selectedImage: UIImage? = nil

    enum BookingStep: Int, CaseIterable {
        case photo = 1
        case describe = 2
        case vehicle = 3
        case price = 4
        case confirm = 5

        var title: String {
            switch self {
            case .photo: return "Ta bilde"
            case .describe: return "Beskriv"
            case .vehicle: return "Biltype"
            case .price: return "Pris"
            case .confirm: return "Bekreft"
            }
        }
    }

    var progress: CGFloat {
        CGFloat(currentStep.rawValue) / CGFloat(BookingStep.allCases.count)
    }

    var canContinue: Bool {
        switch currentStep {
        case .photo: return selectedImage != nil
        case .describe: return !description.trimmingCharacters(in: .whitespaces).isEmpty
        case .vehicle: return selectedVehicle != nil
        case .price: return !price.trimmingCharacters(in: .whitespaces).isEmpty
        case .confirm: return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(spacing: Spacing.md) {
                HStack {
                    Button(action: goBack) {
                        Image(systemName: currentStep == .photo ? "xmark" : "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.kompisTextPrimary)
                    }

                    Spacer()

                    // Kategori-badge
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: category.icon)
                            .font(.system(size: 12))
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.kompisPrimary.opacity(0.1))
                    .foregroundColor(.kompisPrimary)
                    .cornerRadius(CornerRadius.pill)

                    Spacer()

                    Text("\(currentStep.rawValue)/\(BookingStep.allCases.count)")
                        .font(.system(size: 14))
                        .foregroundColor(.kompisTextMuted)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.kompisBgSecondary)
                            .frame(height: 4)

                        Capsule()
                            .fill(Color.kompisPrimary)
                            .frame(width: geometry.size.width * progress, height: 4)
                            .animation(.spring(response: 0.3), value: progress)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.sm)

            // MARK: - Step content
            Group {
                switch currentStep {
                case .photo:
                    PhotoStepContent(selectedImage: $selectedImage)
                case .describe:
                    DescribeStepContent(
                        description: $description,
                        pickupAddress: $pickupAddress
                    )
                case .vehicle:
                    VehicleStepContent(selectedVehicle: $selectedVehicle)
                case .price:
                    PriceStepContent(price: $price)
                case .confirm:
                    ConfirmStepContent(
                        category: category,
                        description: description,
                        pickupAddress: pickupAddress,
                        vehicle: selectedVehicle ?? .personbil,
                        price: price
                    )
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            Spacer()

            // MARK: - Bottom button
            VStack(spacing: Spacing.sm) {
                if currentStep == .confirm {
                    if isSaving {
                        ProgressView().tint(.kompisPrimary).frame(height: 54)
                    } else {
                        KompisButton(title: "Publiser oppdrag", style: .primary, icon: "checkmark") {
                            guard let creatorId = authService.currentUser?.id else { return }
                            isSaving = true
                            _Concurrency.Task {
                                do {
                                    try await taskService.opprettOppdrag(
                                        category: category,
                                        description: description,
                                        address: pickupAddress,
                                        price: Int(price) ?? 0,
                                        creatorId: creatorId,
                                        image: selectedImage
                                    )
                                    await MainActor.run {
                                        isSaving = false
                                        onComplete()
                                        dismiss()
                                    }
                                } catch {
                                    await MainActor.run {
                                        isSaving = false
                                        feilmelding = error.localizedDescription
                                        visError = true
                                    }
                                }
                            }
                        }
                    }
                } else {
                    KompisButton(
                        title: "Neste",
                        style: canContinue ? .primary : .outline,
                        icon: "arrow.right"
                    ) {
                        if canContinue {
                            goForward()
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .background(Color.kompisBgPrimary)
        .navigationBarHidden(true)
        .animation(.spring(response: 0.35), value: currentStep)
        .alert("Noe gikk galt", isPresented: $visError) {
            Button("OK") { }
        } message: {
            Text(feilmelding ?? "Prøv igjen")
        }
    }

    func goBack() {
        if currentStep == .photo {
            dismiss()
        } else if let prev = BookingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
        }
    }

    func goForward() {
        if let next = BookingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }
}

// MARK: - Steg 1: Ta bilde

struct PhotoStepContent: View {
    @Binding var selectedImage: UIImage?
    @State private var visImagePicker = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Ta et bilde")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                Text("Vis hva du trenger hjelp med")
                    .font(.system(size: 16))
                    .foregroundColor(.kompisTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.lg)

            if let image = selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))

                    Button(action: { selectedImage = nil }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.kompisTextSecondary)
                            .padding(Spacing.md)
                            .background(Color.kompisBgCard)
                            .clipShape(Circle())
                            .kompisShadow()
                    }
                    .padding(Spacing.md)
                }
                .padding(.horizontal, Spacing.lg)
            } else {
                Button(action: { visImagePicker = true }) {
                    VStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(Color.kompisPrimary.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.kompisPrimary)
                        }
                        Text("Trykk for å velge bilde")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.kompisPrimary)
                        Text("fra kamerarulle eller ta nytt bilde")
                            .font(.system(size: 14))
                            .foregroundColor(.kompisTextMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(Color.kompisPrimary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
                    )
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.top, Spacing.lg)
        .sheet(isPresented: $visImagePicker) {
            ImagePicker(image: $selectedImage)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Steg 2: Beskriv

struct DescribeStepContent: View {
    @Binding var description: String
    @Binding var pickupAddress: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Beskriv oppdraget")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisTextPrimary)
                    Text("Kort og enkelt, hva trenger du hjelp med?")
                        .font(.system(size: 16))
                        .foregroundColor(.kompisTextSecondary)
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Hva skal gjøres?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.kompisTextSecondary)

                    TextEditor(text: $description)
                        .frame(height: 100)
                        .padding(Spacing.md)
                        .background(Color.kompisBgSecondary)
                        .cornerRadius(CornerRadius.md)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("F.eks. Sofa som skal hentes i 2. etasje...")
                                        .foregroundColor(.kompisTextMuted)
                                        .padding(.horizontal, Spacing.lg)
                                        .padding(.vertical, Spacing.lg)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Hvor skal det hentes?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.kompisTextSecondary)

                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.kompisSuccess)
                        TextField("Adresse...", text: $pickupAddress)
                            .font(.system(size: 15))
                    }
                    .padding(Spacing.md)
                    .background(Color.kompisBgSecondary)
                    .cornerRadius(CornerRadius.md)
                }

                HStack(spacing: Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.kompisSecondary)
                    Text("Tips: Nevn etasje, heis, og ca. vekt")
                        .font(.system(size: 13))
                        .foregroundColor(.kompisTextSecondary)
                }
                .padding(Spacing.md)
                .background(Color.kompisSecondary.opacity(0.08))
                .cornerRadius(CornerRadius.sm)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
        }
    }
}

// MARK: - Steg 3: Velg biltype

struct VehicleStepContent: View {
    @Binding var selectedVehicle: VehicleType?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Hvilken bil trengs?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                Text("Velg basert på hva som skal fraktes")
                    .font(.system(size: 16))
                    .foregroundColor(.kompisTextSecondary)
            }
            .padding(.horizontal, Spacing.lg)

            VStack(spacing: Spacing.md) {
                ForEach(VehicleType.allCases, id: \.self) { vehicle in
                    VehicleCard(
                        vehicle: vehicle,
                        isSelected: selectedVehicle == vehicle
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedVehicle = vehicle
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.top, Spacing.lg)
    }
}

struct VehicleCard: View {
    let vehicle: VehicleType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(isSelected ? Color.kompisPrimary : Color.kompisBgSecondary)
                        .frame(width: 64, height: 64)

                    Image(systemName: vehicle.icon)
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? .white : .kompisPrimary)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(vehicle.rawValue)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.kompisTextPrimary)
                    Text(vehicle.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.kompisTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.kompisPrimary)
                }
            }
            .padding(Spacing.lg)
            .background(Color.kompisBgCard)
            .cornerRadius(CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(isSelected ? Color.kompisPrimary : Color.kompisBgSecondary, lineWidth: isSelected ? 2 : 1)
            )
            .kompisShadow()
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Steg 4: Sett pris

struct PriceStepContent: View {
    @Binding var price: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Sett din pris")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisTextPrimary)
                    Text("Hva vil du betale for oppdraget?")
                        .font(.system(size: 16))
                        .foregroundColor(.kompisTextSecondary)
                }

                // Pris-input
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Din pris")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.kompisTextSecondary)

                    HStack(spacing: Spacing.sm) {
                        Text("kr")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.kompisTextSecondary)
                        TextField("0", text: $price)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.kompisPrimary)
                            .keyboardType(.numberPad)
                    }
                    .padding(Spacing.lg)
                    .background(Color.kompisBgSecondary)
                    .cornerRadius(CornerRadius.lg)
                }

                // Tips
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.kompisSecondary)
                    Text("Tips: En rettferdig pris tiltrekker hjelpere raskere")
                        .font(.system(size: 13))
                        .foregroundColor(.kompisTextSecondary)
                }
                .padding(Spacing.md)
                .background(Color.kompisSecondary.opacity(0.08))
                .cornerRadius(CornerRadius.sm)

                // Gebyr-info
                if let priceInt = Int(price), priceInt > 0 {
                    KompisCard {
                        VStack(spacing: Spacing.md) {
                            HStack {
                                Text("Din pris")
                                    .foregroundColor(.kompisTextSecondary)
                                Spacer()
                                Text("kr \(priceInt)")
                                    .foregroundColor(.kompisTextSecondary)
                            }
                            .font(.system(size: 14))

                            HStack {
                                Text("Kompis-gebyr (12%)")
                                    .foregroundColor(.kompisTextSecondary)
                                Spacer()
                                Text("kr \(Int(Double(priceInt) * 0.12))")
                                    .foregroundColor(.kompisTextSecondary)
                            }
                            .font(.system(size: 14))

                            Divider()

                            HStack {
                                Text("Totalt")
                                    .font(.system(size: 16, weight: .semibold))
                                Spacer()
                                Text("kr \(Int(Double(priceInt) * 1.12))")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.kompisPrimary)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
        }
    }
}

// MARK: - Steg 5: Bekreft

struct ConfirmStepContent: View {
    let category: TaskCategory
    let description: String
    let pickupAddress: String
    let vehicle: VehicleType
    let price: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Alt klart!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisTextPrimary)
                    Text("Sjekk at alt stemmer")
                        .font(.system(size: 16))
                        .foregroundColor(.kompisTextSecondary)
                }

                KompisCard {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Bilde
                        HStack(spacing: Spacing.md) {
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(Color.kompisPrimary.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.kompisSuccess)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bilde lagt til")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.kompisTextPrimary)
                                Text("1 bilde")
                                    .font(.system(size: 13))
                                    .foregroundColor(.kompisTextSecondary)
                            }

                            Spacer()
                        }

                        Divider()

                        SummaryRow(
                            icon: category.icon,
                            label: "Kategori",
                            value: category.rawValue
                        )

                        Divider()

                        SummaryRow(
                            icon: "text.alignleft",
                            label: "Beskrivelse",
                            value: description.isEmpty ? "Ikke oppgitt" : description
                        )

                        Divider()

                        SummaryRow(
                            icon: "mappin.circle.fill",
                            label: "Hente-adresse",
                            value: pickupAddress.isEmpty ? "Ikke oppgitt" : pickupAddress
                        )

                        Divider()

                        SummaryRow(
                            icon: vehicle.icon,
                            label: "Biltype",
                            value: vehicle.rawValue
                        )

                        Divider()

                        // Pris
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "banknote")
                                .font(.system(size: 16))
                                .foregroundColor(.kompisAccent)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 1) {
                                Text("Din pris")
                                    .font(.system(size: 12))
                                    .foregroundColor(.kompisTextMuted)
                                Text("kr \(price)")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.kompisPrimary)
                            }

                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.kompisAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.kompisTextMuted)
                Text(value)
                    .font(.system(size: 15))
                    .foregroundColor(.kompisTextPrimary)
                    .lineLimit(3)
            }

            Spacer()
        }
    }
}
