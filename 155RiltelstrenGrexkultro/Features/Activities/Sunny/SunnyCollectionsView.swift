//
//  SunnyCollectionsView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI
import Combine
import PhotosUI

struct SunnyCollectionsView: View {
    @EnvironmentObject private var userData: UserData
    @EnvironmentObject private var activitiesNav: ActivitiesNavigationStore

    @StateObject private var viewModel: SunnyCollectionsViewModel
    @State private var showOutcome = false
    @State private var outcomeStars = 1
    @State private var outcomeSpeedText = ""
    @State private var outcomeDiversityText = ""
    @State private var milestone = false
    @State private var tick = Date()

    private let tickPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(difficulty: ActivityDifficulty) {
        _viewModel = StateObject(wrappedValue: SunnyCollectionsViewModel(difficulty: difficulty))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sunny Collections")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTextPrimary)

                Text("Two frames per theme—\(viewModel.filledSlotCount)/\(viewModel.totalSlots) filled. Session clock runs until you seal the album.")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)

                sessionTimerRow

                ForEach(SunnyAlbumCategory.allCases) { category in
                    categoryBlock(category)
                }

                PrimaryPressButton(title: viewModel.isComplete ? "Finish album" : "Fill every frame to finish") {
                    finish()
                }
                .disabled(!viewModel.isComplete)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .sunnyCollectionsScreenBackground()
        .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
        .sunnyCollectionsNavigationChrome()
        .onReceive(tickPublisher) { tick = $0 }
        .fullScreenCover(isPresented: $showOutcome) {
            ChallengeOutcomeView(
                stars: outcomeStars,
                headline: "Collection ready",
                speedLabel: outcomeSpeedText,
                diversityLabel: outcomeDiversityText,
                showMilestoneBanner: milestone,
                challengeTitle: ChallengeId.sunnyCollections.title,
                onNext: {
                    showOutcome = false
                    activitiesNav.resetToRoot()
                },
                onReview: {
                    showOutcome = false
                },
                onHome: {
                    showOutcome = false
                    activitiesNav.resetToRoot()
                }
            )
            .environmentObject(userData)
        }
    }

    private var sessionTimerRow: some View {
        let elapsed = Int(tick.timeIntervalSince(viewModel.sessionStartedAt))
        let m = elapsed / 60
        let s = elapsed % 60
        return HStack {
            Image(systemName: "timer")
                .foregroundStyle(Color.appAccent)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text("Session timer")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                Text(String(format: "%d:%02d", m, s))
                    .font(.title3.monospacedDigit().weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            Spacer()
        }
        .padding(12)
        .sunnyCollectionsCardChrome(cornerRadius: 14)
    }

    private func categoryBlock(_ category: SunnyAlbumCategory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text(category.framingHint)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                ForEach(0..<SunnyAlbumCategory.photosPerCategory, id: \.self) { idx in
                    pickerCell(category, index: idx)
                }
            }
        }
        .padding(12)
        .sunnyCollectionsCardChrome(cornerRadius: 16)
    }

    private func pickerCell(_ category: SunnyAlbumCategory, index: Int) -> some View {
        let key = SunnyAlbumCategory.slotKey(category, index: index)
        return VStack(spacing: 6) {
            Text("Frame \(index + 1)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)

            PhotosPicker(
                selection: binding(for: category, index: index),
                matching: .images
            ) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(SunnyCollectionsChrome.surfaceFill)
                        .frame(height: 120)

                    if let image = viewModel.previewImages[key] {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title3)
                                .foregroundStyle(Color.appAccent)
                            Text("Add")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private func binding(for category: SunnyAlbumCategory, index: Int) -> Binding<PhotosPickerItem?> {
        let key = SunnyAlbumCategory.slotKey(category, index: index)
        return Binding(
            get: { viewModel.pickers[key] ?? nil },
            set: { viewModel.bind(item: $0, category: category, index: index) }
        )
    }

    private func finish() {
        let result = viewModel.outcome()
        outcomeStars = result.stars
        outcomeSpeedText = "\(result.speedSeconds)s adjusted pace"
        outcomeDiversityText = "\(result.diversity)/3 themes doubled up"

        let before = userData.records.count
        userData.recordChallengeCompletion(
            challengeId: ChallengeId.sunnyCollections.rawValue,
            title: ChallengeId.sunnyCollections.title,
            starsEarned: result.stars,
            summaryLine: result.summary,
            durationSeconds: result.speedSeconds,
            uniquenessPoints: result.diversity
        )

        milestone = before < 5 && userData.records.count >= 5

        showOutcome = true
    }
}

// MARK: - Local chrome (mirrors AppChrome; keeps this file building if theme helpers are unavailable)

private enum SunnyCollectionsChrome {
    static var surfaceFill: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(1),
                Color.appSurface.opacity(0.82)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private static var cardBorder: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.14),
                Color.appAccent.opacity(0.28),
                Color.appPrimary.opacity(0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func elevatedPlate(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(surfaceFill)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.38), radius: 12, x: 0, y: 7)
            .shadow(color: Color.appAccent.opacity(0.12), radius: 18, x: 0, y: 10)
    }
}

private extension View {
    func sunnyCollectionsScreenBackground() -> some View {
        background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.appPrimary.opacity(0.28),
                        Color.appBackground,
                        Color.appSurface.opacity(0.45),
                        Color.appBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                LinearGradient(
                    colors: [Color.black.opacity(0), Color.black.opacity(0.42)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        }
    }

    func sunnyCollectionsNavigationChrome() -> some View {
        toolbarBackground(
            LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.97),
                    Color.appSurface.opacity(0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            for: .navigationBar
        )
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    func sunnyCollectionsCardChrome(cornerRadius: CGFloat) -> some View {
        background {
            SunnyCollectionsChrome.elevatedPlate(cornerRadius: cornerRadius)
        }
    }
}
