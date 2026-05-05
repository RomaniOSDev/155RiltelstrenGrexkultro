//
//  RainyBreathingView.swift
//  155RiltelstrenGrexkultro
//

import Combine
import SwiftUI
import UIKit

struct RainyBreathingView: View {
    @EnvironmentObject private var userData: UserData
    @EnvironmentObject private var activitiesNav: ActivitiesNavigationStore

    @StateObject private var viewModel: RainyBreathingViewModel
    @State private var showOutcome = false
    @State private var outcomeStars = 1
    @State private var rhythmText = ""
    @State private var focusText = ""
    @State private var milestone = false
    @State private var lockedOutcome = false
    @State private var selectedPreset: BreathingPreset = .balanced

    init(difficulty: ActivityDifficulty) {
        _viewModel = StateObject(wrappedValue: RainyBreathingViewModel(difficulty: difficulty, preset: .balanced))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Rainy Day Rejuvenation")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTextPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Breathing curve")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                    Picker("Curve", selection: $selectedPreset) {
                        ForEach(BreathingPreset.allCases) { p in
                            Text(p.title).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedPreset) { newValue in
                        viewModel.updatePreset(newValue)
                    }
                    Text(selectedPreset.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(12)
                .appCardChrome(cornerRadius: 14)

                Text(viewModel.phase == .hold ? "Quiet pause" : "Follow the circle — tap when the soft band glows.")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                ZStack {
                    Circle()
                        .strokeBorder(Color.appSurface, lineWidth: 14)
                        .frame(width: 220, height: 220)

                    Circle()
                        .trim(from: 0, to: viewModel.phaseProgress)
                        .stroke(
                            Color.appAccent,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 210, height: 210)

                    Text(phaseLabel)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .scaleEffect(viewModel.pulseScale)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.pulseScale)
                .onTapGesture {
                    viewModel.handleTap()
                    if userData.rainyHapticsEnabled {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                .padding(.vertical, 8)
                .shadow(color: Color.black.opacity(0.35), radius: 24, x: 0, y: 12)
                .shadow(color: Color.appAccent.opacity(0.22), radius: 28, x: 0, y: 10)
                .accessibilityAddTraits(.isButton)

                ProgressView(value: Double(viewModel.cycleIndex), total: Double(3))
                    .tint(Color.appPrimary)
                    .padding(.horizontal, 16)

                PrimaryPressButton(title: viewModel.isFinished ? "View results" : "Keep breathing…") {
                    if viewModel.isFinished {
                        presentOutcome()
                    }
                }
                .disabled(!viewModel.isFinished)
                .opacity(viewModel.isFinished ? 1 : 0.45)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .fullScreenCover(isPresented: $showOutcome) {
            ChallengeOutcomeView(
                stars: outcomeStars,
                headline: "Breathing arc complete",
                speedLabel: focusText,
                diversityLabel: rhythmText,
                showMilestoneBanner: milestone,
                challengeTitle: ChallengeId.rainyRejuvenation.title,
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

    private var phaseLabel: String {
        switch viewModel.phase {
        case .inhale: return "Inhale gently"
        case .hold: return "Hold soft and steady"
        case .exhale: return "Release slowly"
        }
    }

    private func presentOutcome() {
        guard !lockedOutcome else { return }
        lockedOutcome = true

        let result = viewModel.outcome()
        outcomeStars = result.stars
        focusText = "Session focus \(result.focusScore)%"
        rhythmText = result.rhythmLabel

        let before = userData.records.count
        userData.recordChallengeCompletion(
            challengeId: ChallengeId.rainyRejuvenation.rawValue,
            title: ChallengeId.rainyRejuvenation.title,
            starsEarned: result.stars,
            summaryLine: result.summary,
            durationSeconds: result.duration,
            uniquenessPoints: result.taps
        )
        milestone = before < 5 && userData.records.count >= 5
        showOutcome = true
    }
}
