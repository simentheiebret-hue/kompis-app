//
//  OppdragKort.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct OppdragKort: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Bilde med kategori-badge
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.kompisBgSecondary)
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: task.category.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.kompisTextMuted)
                    )
                
                KompisBadge(text: task.category.rawValue, variant: .category)
                    .padding(Spacing.md)
            }
            .cornerRadius(CornerRadius.lg, corners: [.topLeft, .topRight])
            
            // Innhold
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.kompisAccent)
                    Text(task.pickupLocation.city ?? "Oslo")
                    Text("•")
                    Text(String(format: "%.1f km", task.distance))
                }
                .font(.system(size: 13))
                .foregroundColor(.kompisTextSecondary)
                
                HStack {
                    KompisBadge(text: "\(task.price) kr", variant: .price)
                    
                    Spacer()
                    
                    // Avatar placeholder
                    Circle()
                        .fill(Color.kompisBgSecondary)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(task.createdBy.name.prefix(1)))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.kompisTextSecondary)
                        )
                }
            }
            .padding(Spacing.md)
        }
        .background(Color.kompisBgCard)
        .cornerRadius(CornerRadius.lg)
        .kompisShadow()
    }
}

// Helper for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
