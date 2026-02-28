//
//  GlassesApp.swift
//  Glasses
//
//  Created by Luca Langella 1 on 2/25/26.
//

import SwiftUI

@main
struct GlassesApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}
