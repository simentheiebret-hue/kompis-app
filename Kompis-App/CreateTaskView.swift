//
//  CreateTaskView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct CreateTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 1
    @State private var selectedCategory: TaskCategory? = nil
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header med progress
                VStack(spacing: Spacing.md) {
                    HStack {
                        Button(action: {
                            if currentStep > 1 {
                                currentStep -= 1
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: currentStep == 1 ? "xmark" : "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.kompisTextPrimary)
                        }
                        
                        Spacer()
                        
                        Text("Steg \(currentStep) av 5")
                            .font(.system(size: 14))
                            .foregroundColor(.kompisTextSecondary)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.kompisBgSecondary)
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(Color.kompisPrimary)
                                .frame(width: geometry.size.width * CGFloat(currentStep) / 5, height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(Spacing.lg)
                
                // Step content
                TabView(selection: $currentStep) {
                    // Step 1: Kategori
                    CategoryStepView(selectedCategory: $selectedCategory)
                        .tag(1)
                    
                    // Step 2: Bilder
                    PhotosStepView()
                        .tag(2)
                    
                    // Step 3: Detaljer
                    DetailsStepView(title: $title, description: $description)
                        .tag(3)
                    
                    // Step 4: Lokasjon
                    LocationStepView()
                        .tag(4)
                    
                    // Step 5: Pris
                    PriceStepView(price: $price)
                        .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Neste-knapp
                if currentStep < 5 {
                    KompisButton(title: "Neste", style: .primary, icon: "arrow.right") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .padding(Spacing.lg)
                } else {
                    KompisButton(title: "Publiser oppdrag", style: .secondary, icon: "checkmark") {
                        dismiss()
                    }
                    .padding(Spacing.lg)
                }
            }
            .background(Color.kompisBgPrimary)
            .navigationBarHidden(true)
        }
    }
}

struct CategoryStepView: View {
    @Binding var selectedCategory: TaskCategory?
    
    let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            Text("Hva trenger du\nhjelp med?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.kompisTextPrimary)
            
            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    CategorySelectCard(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            
            Spacer()
        }
        .padding(Spacing.lg)
    }
}

struct CategorySelectCard: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.md) {
                Image(systemName: category.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : .kompisPrimary)
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .kompisTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xl)
            .background(isSelected ? Color.kompisPrimary : Color.kompisBgCard)
            .cornerRadius(CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(isSelected ? Color.clear : Color.kompisBgSecondary, lineWidth: 1)
            )
            .kompisShadow()
        }
    }
}

struct PhotosStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Legg til bilder")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                
                Text("Gode bilder hjelper deg å finne en Kompis raskere ✨")
                    .font(.system(size: 16))
                    .foregroundColor(.kompisTextSecondary)
            }
            
            // Upload area
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(Color.kompisPrimary, style: StrokeStyle(lineWidth: 2, dash: [8]))
                .frame(height: 200)
                .overlay(
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.kompisPrimary)
                        
                        Text("Ta bilde eller velg fra biblioteket")
                            .font(.system(size: 14))
                            .foregroundColor(.kompisTextSecondary)
                    }
                )
            
            Spacer()
        }
        .padding(Spacing.lg)
    }
}

struct DetailsStepView: View {
    @Binding var title: String
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            Text("Beskriv oppdraget")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.kompisTextPrimary)
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Tittel")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.kompisTextSecondary)
                
                TextField("F.eks. Hente sofa fra Finn", text: $title)
                    .padding(Spacing.lg)
                    .background(Color.kompisBgSecondary)
                    .cornerRadius(CornerRadius.md)
            }
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Beskrivelse")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.kompisTextSecondary)
                
                TextEditor(text: $description)
                    .frame(height: 120)
                    .padding(Spacing.md)
                    .background(Color.kompisBgSecondary)
                    .cornerRadius(CornerRadius.md)
            }
            
            HStack(spacing: Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.kompisSecondary)
                Text("Tips: Jo mer detaljer, jo lettere er det å finne riktig hjelper")
                    .font(.system(size: 13))
                    .foregroundColor(.kompisTextSecondary)
            }
            
            Spacer()
        }
        .padding(Spacing.lg)
    }
}

struct LocationStepView: View {
    @State private var pickupAddress = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            Text("Hvor skal det hentes?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.kompisTextPrimary)
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.kompisSecondary)
                TextField("Søk adresse...", text: $pickupAddress)
            }
            .padding(Spacing.lg)
            .background(Color.kompisBgSecondary)
            .cornerRadius(CornerRadius.md)
            
            // Kart placeholder
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color.kompisBgSecondary)
                .frame(height: 200)
                .overlay(
                    Image(systemName: "map")
                        .font(.system(size: 40))
                        .foregroundColor(.kompisTextMuted)
                )
            
            Spacer()
        }
        .padding(Spacing.lg)
    }
}

struct PriceStepView: View {
    @Binding var price: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            Text("Sett din pris")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.kompisTextPrimary)
            
            // AI-forslag
            KompisCard {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.kompisSecondary)
                        Text("Foreslått pris basert på lignende oppdrag:")
                            .font(.system(size: 14))
                            .foregroundColor(.kompisTextSecondary)
                    }
                    
                    Text("kr 350")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisPrimary)
                    
                    Button("Bruk forslag") {
                        price = "350"
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.kompisPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
            }
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Eller sett egen pris")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.kompisTextSecondary)
                
                HStack {
                    Text("kr")
                        .foregroundColor(.kompisTextSecondary)
                    TextField("0", text: $price)
                        .keyboardType(.numberPad)
                }
                .padding(Spacing.lg)
                .background(Color.kompisBgSecondary)
                .cornerRadius(CornerRadius.md)
            }
            
            // Oppsummering
            KompisCard {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("Din pris")
                        Spacer()
                        Text("kr \(price.isEmpty ? "0" : price)")
                    }
                    .foregroundColor(.kompisTextSecondary)
                    
                    HStack {
                        Text("Kompis-gebyr (12%)")
                        Spacer()
                        Text("kr \(Int((Double(price) ?? 0) * 0.12))")
                    }
                    .foregroundColor(.kompisTextSecondary)
                    
                    Divider()
                    
                    HStack {
                        Text("Totalt å betale")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("kr \(Int((Double(price) ?? 0) * 1.12))")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.kompisTextPrimary)
                }
            }
            
            Spacer()
        }
        .padding(Spacing.lg)
    }
}
