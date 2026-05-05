//
//  ActivitySelectionView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

struct ActivitySelectionView: View {
    let laneTitle: String
    @EnvironmentObject private var userData: UserData
    @State private var difficulty: ActivityDifficulty = .medium

    var body: some View {
        List {
            Section {
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(ActivityDifficulty.allCases) { level in
                        Text(level.title).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppChrome.surfaceFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(AppChrome.cardBorder.opacity(0.5), lineWidth: 0.5)
                        )
                )
            } header: {
                Text("Difficulty shapes pacing")
                    .foregroundStyle(Color.appTextSecondary)
            }

            Section {
                challengeRow(for: .sunnyCollections)
                challengeRow(for: .rainyRejuvenation)
                challengeRow(for: .winterWardrobe)
            } header: {
                Text("Challenges")
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .scrollContentBackground(.hidden)
        .appScreenBackground()
        .navigationTitle("Routes")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
    }

    @ViewBuilder
    private func challengeRow(for challenge: ChallengeId) -> some View {
        let unlocked = userData.isUnlocked(challengeId: challenge)
        if unlocked {
            NavigationLink(value: destination(for: challenge)) {
                rowLabel(challenge: challenge, locked: false)
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppChrome.surfaceFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(AppChrome.cardBorder.opacity(0.5), lineWidth: 0.5)
                    )
            )
        } else {
            HStack {
                rowLabel(challenge: challenge, locked: true)
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appSurface.opacity(0.58), Color.appSurface.opacity(0.42)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
    }

    private func rowLabel(challenge: ChallengeId, locked: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: locked ? "lock.fill" : "chevron.forward.circle.fill")
                .foregroundStyle(locked ? Color.appTextSecondary : Color.appAccent)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(locked ? "Complete the prior route to unlock." : laneTitle)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private func destination(for challenge: ChallengeId) -> ActivityDestination {
        switch challenge {
        case .sunnyCollections:
            return .sunny(difficulty)
        case .rainyRejuvenation:
            return .rainy(difficulty)
        case .winterWardrobe:
            return .winter(difficulty)
        }
    }
}
