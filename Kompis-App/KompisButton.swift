//
//  KompisButton.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct KompisButton: View {
    enum Style {
        case primary, secondary, outline, ghost
    }
    
    let title: String
    let style: Style
    var icon: String? = nil
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .padding(.horizontal, Spacing.xl)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(CornerRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.pill)
                    .stroke(borderColor, lineWidth: style == .outline ? 2 : 0)
            )
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return .kompisPrimary
        case .secondary: return .kompisSecondary
        case .outline, .ghost: return .clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary: return .white
        case .outline, .ghost: return .kompisPrimary
        }
    }
    
    private var borderColor: Color {
        style == .outline ? .kompisPrimary : .clear
    }
}
