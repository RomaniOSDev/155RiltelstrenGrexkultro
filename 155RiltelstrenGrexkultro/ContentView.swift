//
//  ContentView.swift
//  155RiltelstrenGrexkultro
//
//  Created by Roman on 5/4/26.
//

import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var userData = UserData()
    @StateObject private var activitiesNav = ActivitiesNavigationStore()

    var body: some View {
        Group {
            if userData.hasSeenOnboarding {
                MainTabShellView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(userData)
        .environmentObject(activitiesNav)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
