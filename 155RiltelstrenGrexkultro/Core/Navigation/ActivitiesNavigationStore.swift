//
//  ActivitiesNavigationStore.swift
//  155RiltelstrenGrexkultro
//

import Combine
import SwiftUI

enum ActivityDestination: Hashable {
    case selectionLane(String)
    case sunny(ActivityDifficulty)
    case rainy(ActivityDifficulty)
    case winter(ActivityDifficulty)
}

final class ActivitiesNavigationStore: ObservableObject {
    @Published var path = NavigationPath()

    func resetToRoot() {
        path = NavigationPath()
    }
}
