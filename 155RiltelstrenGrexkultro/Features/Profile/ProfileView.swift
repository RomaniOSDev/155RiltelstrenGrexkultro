//
//  ProfileView.swift
//  155RiltelstrenGrexkultro
//

import StoreKit
import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var userData: UserData
    @State private var isSharePresented = false
    @State private var sharePayload: [Any] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        summaryTile(
                            title: "Stars",
                            value: "\(userData.collectedStars)",
                            symbol: "star.fill"
                        )
                        summaryTile(
                            title: "Routes",
                            value: "\(userData.completedChallengeIds.count)",
                            symbol: "map.fill"
                        )
                        summaryTile(
                            title: "Level",
                            value: "\(userData.currentLevel)",
                            symbol: "chart.line.uptrend.xyaxis"
                        )
                    }
                    .padding(.horizontal, 4)

                    achievementsSection

                    diaryMoodChart

                    Text("Recent finishes")
                        .font(.title3.bold())
                        .foregroundStyle(Color.appTextPrimary)

                    if userData.records.isEmpty {
                        Text("Complete a challenge to see your trail here.")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(.vertical, 8)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(userData.records) { record in
                                recordCard(record)
                                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
                            }
                        }
                        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: userData.records)
                    }

                    NavigationLink {
                        SettingsView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(Color.appAccent)
                                .frame(width: 44, height: 44)
                            Text("Open settings")
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

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Support & legal")
                            .font(.title3.bold())
                            .foregroundStyle(Color.appTextPrimary)

                        profileLinkRow(
                            title: "Rate us",
                            symbol: "star.circle.fill"
                        ) {
                            rateApp()
                        }

                        profileLinkRow(
                            title: "Privacy Policy",
                            symbol: "hand.raised.fill"
                        ) {
                            openPolicy(.privacyPolicy)
                        }

                        profileLinkRow(
                            title: "Terms of Use",
                            symbol: "doc.text.fill"
                        ) {
                            openPolicy(.termsOfUse)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(16)
            }
            .appScreenBackground()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        prepareShare()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.appAccent)
                    }
                    .accessibilityLabel("Share moment card")
                }
            }
            .sheet(isPresented: $isSharePresented) {
                ActivityShareSheet(items: sharePayload)
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)

            achievementRow(
                title: "Seasoned explorer",
                detail: "Finish five challenge journeys.",
                unlocked: userData.hasSeasonedExplorerAchievement,
                symbol: "map.fill"
            )
            achievementRow(
                title: "Sky mix",
                detail: "Log three different day scenarios within a week.",
                unlocked: userData.hasWeatherMixAchievement,
                symbol: "cloud.sun.fill"
            )
            achievementRow(
                title: "Discover regular",
                detail: "Open Discover on seven consecutive days.",
                unlocked: userData.hasDiscoverStreak7,
                symbol: "sparkles"
            )
        }
    }

    private func achievementRow(title: String, detail: String, unlocked: Bool, symbol: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(unlocked ? Color.appAccent : Color.appTextSecondary.opacity(0.5))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(unlocked ? Color.appPrimary.opacity(0.25) : Color.appSurface)
                )
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    if unlocked {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appPrimary)
                    }
                }
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardChrome(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.appAccent.opacity(unlocked ? 0.42 : 0), lineWidth: 1.25)
        )
        .opacity(unlocked ? 1 : 0.72)
    }

    private var diaryMoodChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Journal moods (14 days)")
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)

            let data = userData.diaryMoodCountsLastFortnight
            let maxVal = max(1, data.map(\.count).max() ?? 1)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(data, id: \.mood.id) { row in
                    VStack(spacing: 6) {
                        Text("\(row.count)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimary.opacity(0.95), Color.appAccent.opacity(0.65)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: CGFloat(row.count) / CGFloat(maxVal) * 72)
                            .frame(maxWidth: .infinity)
                            .shadow(color: Color.appPrimary.opacity(0.35), radius: 4, y: 2)
                        Image(systemName: row.mood.symbolName)
                            .font(.caption)
                            .foregroundStyle(Color.appAccent)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 110)
            .padding(14)
            .appCardChrome(cornerRadius: 16)

            if data.allSatisfy({ $0.count == 0 }) {
                Text("Log how a session felt after a challenge to see this fill in.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }

    private func prepareShare() {
        let line = "A calm outdoor rhythm—shared as art, not GPS."
        guard let data = ShareMomentCardRender.pngData(scenario: userData.selectedScenario, accentLine: line),
              let img = UIImage(data: data) else { return }
        sharePayload = [img]
        isSharePresented = true
    }

    private func openPolicy(_ policy: AppPolicyURL) {
        if let url = URL(string: policy.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func profileLinkRow(
        title: String,
        symbol: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 44, height: 44)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "arrow.up.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(16)
            .appCardChrome(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    private func summaryTile(title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(Color.appPrimary)
                .frame(height: 26)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardChrome(cornerRadius: 16)
    }

    private func recordCard(_ record: ChallengeCompletionRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                HStack(spacing: 4) {
                    ForEach(0..<record.starsEarned, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.appPrimary)
                            .font(.caption)
                    }
                }
            }
            Text(record.summaryLine)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(record.completedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardChrome(cornerRadius: 16)
    }
}
