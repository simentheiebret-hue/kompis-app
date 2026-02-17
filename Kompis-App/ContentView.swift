//
//  ContentView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .home
    @State private var showCreateTask = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .feed:
                    FeedView()
                case .create:
                    EmptyView()
                case .activity:
                    ActivityView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            KompisTabBar(selectedTab: $selectedTab, showCreateTask: $showCreateTask)
        }
        .background(Color.kompisBgPrimary)
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $showCreateTask) {
            BookingFlowView(category: .other) {
                // Etter fullført bestilling
            }
        }
    }
}

#Preview {
    ContentView()
}
