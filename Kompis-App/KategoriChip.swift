//
//  KategoriChip.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct KategoriChip: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: category.icon)
                Text(category.rawValue)
                    .fontWeight(.medium)
            }
            .font(.system(size: 14))
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(isSelected ? Color.kompisPrimary : Color.kompisBgSecondary)
            .foregroundColor(isSelected ? .white : .kompisTextPrimary)
            .cornerRadius(CornerRadius.pill)
        }
    }
}
