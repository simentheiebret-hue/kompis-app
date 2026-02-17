//
//  Colors.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

extension Color {
    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Primærfarger
    static let kompisPrimary = Color(hex: "#2D5A4A")      // Dyp skoggrønn
    static let kompisSecondary = Color(hex: "#E8985E")    // Varm terrakotta
    static let kompisAccent = Color(hex: "#5B8F7E")       // Lys salvie

    // Bakgrunner – nå mørkere for glassmorphism-kontrast
    static let kompisBgPrimary = Color(hex: "#0F1C17")    // Dyp natt-grønn
    static let kompisBgSecondary = Color(hex: "#1A2E26")  // Mørk skoggrønn
    static let kompisBgCard = Color(hex: "#FFFFFF")       // Hvit for kort

    // Glass-overflater
    static let kompisGlassBg = Color.white.opacity(0.08)
    static let kompisGlassBorder = Color.white.opacity(0.15)
    static let kompisGlassHighlight = Color.white.opacity(0.25)

    // Gradient-bakgrunn
    static let kompisGradientTop = Color(hex: "#0F1C17")
    static let kompisGradientBottom = Color(hex: "#1E3D2F")

    // Tekst
    static let kompisTextPrimary = Color(hex: "#F0F7F3")   // Lys på mørk bakgrunn
    static let kompisTextSecondary = Color(hex: "#A8C4B8") // Dempet lys grønn
    static let kompisTextMuted = Color(hex: "#5B7A6E")     // Muted

    // Status
    static let kompisSuccess = Color(hex: "#4CAF50")
    static let kompisWarning = Color(hex: "#E8985E")
    static let kompisError = Color(hex: "#D64545")
}

// Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

// Corner Radius
enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let pill: CGFloat = 9999
}

// Shadow Modifier
extension View {
    func kompisShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 8)
    }

    func glassCard(cornerRadius: CGFloat = CornerRadius.xl) -> some View {
        self
            .background(
                ZStack {
                    // Frosted glass base
                    Color.kompisGlassBg
                    // Subtle top highlight
                    LinearGradient(
                        colors: [Color.kompisGlassHighlight, Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.kompisGlassBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
    }

    func glassMaterial(cornerRadius: CGFloat = CornerRadius.xl) -> some View {
        self
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
