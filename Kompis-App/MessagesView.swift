//
//  MessagesView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct MessagesView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Meldinger")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.kompisTextPrimary)
                    .padding(.horizontal, Spacing.lg)
                
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        ForEach(MockData.users) { user in
                            MessageRow(user: user, lastMessage: "Hei! Kan du hente i dag?", time: "14:32")
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    Spacer(minLength: 100)
                }
            }
            .padding(.top, Spacing.lg)
            .background(Color.kompisBgPrimary)
            .navigationBarHidden(true)
        }
    }
}

struct MessageRow: View {
    let user: User
    let lastMessage: String
    let time: String
    
    var body: some View {
        KompisCard {
            HStack(spacing: Spacing.md) {
                Circle()
                    .fill(Color.kompisBgSecondary)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.kompisTextSecondary)
                    )
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(user.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.kompisTextPrimary)
                        Spacer()
                        Text(time)
                            .font(.system(size: 12))
                            .foregroundColor(.kompisTextMuted)
                    }
                    
                    Text(lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.kompisTextSecondary)
                        .lineLimit(1)
                }
            }
        }
    }
}
