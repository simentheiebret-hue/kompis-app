//
//  KompisCard.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct KompisCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.lg)
            .background(Color.kompisBgCard)
            .cornerRadius(CornerRadius.lg)
            .kompisShadow()
    }
}
