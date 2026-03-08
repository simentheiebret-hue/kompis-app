//
//  Kompis_AppApp.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

@main
struct Kompis_AppApp: App {
    @StateObject var authService = AuthService()
    @State var taskService = TaskService()
    @State var profileService = ProfileService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environment(taskService)
                .environment(profileService)
                .onOpenURL { url in
                    authService.haandterOAuthCallback(url: url)
                }
        }
    }
}
