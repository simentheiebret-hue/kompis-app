//
//  KompisBadge.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct KompisBadge: View {
    enum Variant {
        case category, price, status, info
    }
    
    let text: String
    let variant: Variant
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(CornerRadius.pill)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .category: return .kompisPrimary
        case .price: return .kompisSecondary
        case .status: return .kompisAccent
        case .info: return .kompisBgSecondary
        }
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .category, .price, .status: return .white
        case .info: return .kompisTextSecondary
        }
    }
}
