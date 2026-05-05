//
//  MainTabCoordinator.swift
//  155RiltelstrenGrexkultro
//

import Combine
import SwiftUI

@MainActor
final class MainTabCoordinator: ObservableObject {
    @Published var selection: MainTab = .home

    func open(_ tab: MainTab) {
        selection = tab
    }
}
