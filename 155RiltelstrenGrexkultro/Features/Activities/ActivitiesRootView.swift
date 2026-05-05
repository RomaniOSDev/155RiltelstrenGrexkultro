//
//  ActivitiesRootView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

private struct MoodLane: Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
    let hint: String
}

struct ActivitiesRootView: View {
    @EnvironmentObject private var activitiesNav: ActivitiesNavigationStore
    @State private var lane: MoodLane?

    private let lanes: [MoodLane] = [
        MoodLane(title: "Sunny Explorations", symbol: "sun.max.fill", hint: "Bright outings, lenses ready, gentle pacing."),
        MoodLane(title: "Cozy Indoor Scenes", symbol: "house.fill", hint: "Soft light chores, reading nooks, warm drinks."),
        MoodLane(title: "Breezy Quick Trips", symbol: "wind", hint: "Short errands, packable layers, flexible routes.")
    ]

    var body: some View {
        NavigationStack(path: $activitiesNav.path) {
            ScrollView {
                mainStack
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: lane?.id)
            .appScreenBackground()
            .navigationTitle("Activities")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .navigationDestination(for: ActivityDestination.self, destination: destinationContent)
        }
    }

    private var mainStack: some View {
        VStack(spacing: 16) {
            pickerTitle
            laneButtonList

            if let selected = lane {
                selectedLaneCard(selected)
            }

            Spacer(minLength: 24)
        }
        .padding(.top, 12)
    }

    private var pickerTitle: some View {
        Text("Pick a mood lane")
            .font(.title3.bold())
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }

    private var laneButtonList: some View {
        VStack(spacing: 12) {
            ForEach(lanes) { item in
                laneRowButton(item)
            }
        }
        .padding(.horizontal, 16)
    }

    private func laneRowButton(_ item: MoodLane) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                lane = item
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.symbol)
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 44, height: 44)
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(16)
            .appCardChrome(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    private func selectedLaneCard(_ lane: MoodLane) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: lane.symbol)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 44, height: 44)
                Text(lane.hint)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                activitiesNav.path.append(ActivityDestination.selectionLane(lane.title))
            } label: {
                openRoutesLabel
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(cardChrome)
        .padding(.horizontal, 16)
        .transition(.slide)
    }

    private var openRoutesLabel: some View {
        Text("Open activity routes")
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppChrome.primaryButtonFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
            )
    }

    private var cardChrome: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(AppChrome.surfaceFill)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(AppChrome.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
            .subtleGlowShadow()
    }

    @ViewBuilder
    private func destinationContent(_ destination: ActivityDestination) -> some View {
        switch destination {
        case .selectionLane(let title):
            ActivitySelectionView(laneTitle: title)
        case .sunny(let difficulty):
            SunnyCollectionsView(difficulty: difficulty)
        case .rainy(let difficulty):
            RainyBreathingView(difficulty: difficulty)
        case .winter(let difficulty):
            WinterWardrobeView(difficulty: difficulty)
        }
    }
}
