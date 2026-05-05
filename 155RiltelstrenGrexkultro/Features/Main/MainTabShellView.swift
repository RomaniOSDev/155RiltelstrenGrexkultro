//
//  MainTabShellView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI
import UIKit
import Combine

struct MainTabShellView: View {
    @EnvironmentObject private var activitiesNav: ActivitiesNavigationStore
    @StateObject private var tabCoordinator = MainTabCoordinator()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tabCoordinator.selection) {
                HomeView()
                    .tag(MainTab.home)

                DiscoverView()
                    .tag(MainTab.discover)

                ActivitiesRootView()
                    .tag(MainTab.activities)

                ProfileView()
                    .tag(MainTab.profile)
            }
            .tabViewStyle(.automatic)

            CustomTabBarView(selection: $tabCoordinator.selection)
        }
        .environmentObject(tabCoordinator)
        .onAppear {
            UITabBar.appearance().isHidden = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDataDidReset)) { _ in
            activitiesNav.resetToRoot()
        }
        .background(
            ZStack {
                AppChrome.screenGradient
                AppChrome.screenVignette
            }
            .ignoresSafeArea()
        )
    }
}
