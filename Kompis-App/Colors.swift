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

    // Primærfarger (originale)
    static let kompisPrimary   = Color(hex: "#2D5A4A")   // Dyp skoggrønn
    static let kompisSecondary = Color(hex: "#E8985E")   // Varm terrakotta
    static let kompisAccent    = Color(hex: "#5B8F7E")   // Lys salvie

    // Bakgrunner (originale, lyse)
    static let kompisBgPrimary   = Color(hex: "#FDFBF7") // Varm cream
    static let kompisBgSecondary = Color(hex: "#F5F1EA") // Lys beige
    static let kompisBgCard      = Color(hex: "#FFFFFF") // Hvit

    // Tekst (originale)
    static let kompisTextPrimary   = Color(hex: "#1A2E26") // Mørk grønn-svart
    static let kompisTextSecondary = Color(hex: "#6B7B75") // Dempet grå-grønn
    static let kompisTextMuted     = Color(hex: "#A3ADA8") // Lys grå

    // Status
    static let kompisSuccess = Color(hex: "#4CAF50")
    static let kompisWarning = Color(hex: "#E8985E")
    static let kompisError   = Color(hex: "#D64545")

    // Støttefarger for moderne kort og seksjoner
    static let kompisSurface  = Color(hex: "#F0EDE7")    // Litt varmere enn kort, for seksjoner
    static let kompisDivider  = Color(hex: "#E8E3DA")    // Subtil skillelinje
}

// Spacing
enum Spacing {
    static let xs: CGFloat  = 4
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 12
    static let lg: CGFloat  = 16
    static let xl: CGFloat  = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

// Corner Radius
enum CornerRadius {
    static let sm: CGFloat   = 8
    static let md: CGFloat   = 12
    static let lg: CGFloat   = 16
    static let xl: CGFloat   = 24
    static let xxl: CGFloat  = 32
    static let pill: CGFloat = 9999
}

// MARK: - View Modifiers

extension View {
    /// Standard skygge (lett, lys bakgrunn)
    func kompisShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: 4)
    }

    /// Kraftigere, varmere skygge for hero-elementer
    func kompisElevated() -> some View {
        self.shadow(color: Color(hex: "#2D5A4A").opacity(0.12), radius: 20, x: 0, y: 8)
    }

    /// Hvit kort-bakgrunn med runding og skygge
    func kompisCard(radius: CGFloat = CornerRadius.xl) -> some View {
        self
            .background(Color.kompisBgCard)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 5)
    }

    /// Varm overflate-bakgrunn (beige-tone) med runding
    func kompisSurface(radius: CGFloat = CornerRadius.xl) -> some View {
        self
            .background(Color.kompisSurface)
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}
