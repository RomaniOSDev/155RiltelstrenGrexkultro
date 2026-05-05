//
//  ChallengeOutcomeView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

struct ChallengeOutcomeView: View {
    let stars: Int
    let headline: String
    let speedLabel: String
    let diversityLabel: String
    let showMilestoneBanner: Bool
    let challengeTitle: String
    let onNext: () -> Void
    let onReview: () -> Void
    let onHome: () -> Void

    @EnvironmentObject private var userData: UserData
    @State private var revealedStars = 0
    @State private var bannerOffset: CGFloat = -220
    @State private var reflectionMood: ReflectionMood?
    @State private var reflectionNote: String = ""
    @State private var reflectionSaved = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                milestoneBanner

                Text(headline)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                HStack(spacing: 18) {
                    ForEach(0..<3, id: \.self) { index in
                        let active = index < min(3, stars)
                        Image(systemName: active ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.appPrimary)
                            .scaleEffect(index < revealedStars ? 1 : 0.3)
                            .opacity(index < revealedStars ? 1 : 0.15)
                            .shadow(color: index < revealedStars ? Color.appAccent : .clear, radius: 10)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.7),
                                value: revealedStars
                            )
                    }
                }
                .padding(.vertical, 8)

                VStack(alignment: .leading, spacing: 12) {
                    statRow(title: "Pace insight", value: speedLabel)
                    statRow(title: "Variety", value: diversityLabel)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardChrome(cornerRadius: 18)
                .padding(.horizontal, 16)

                reflectionBlock

                VStack(spacing: 12) {
                    PrimaryPressButton(title: "Next Adventure", action: onNext)
                    SecondaryPressButton(title: "Review Challenge", action: onReview)
                    SecondaryPressButton(title: "Back to Main", action: onHome)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
        .appScreenBackground()
        .onAppear {
            animateEntrance()
        }
    }

    @ViewBuilder
    private var reflectionBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick log")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            if reflectionSaved {
                Text("Saved to your journal.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appAccent)
            } else {
                Text("How did it feel?")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)

                HStack(spacing: 10) {
                    ForEach(ReflectionMood.allCases) { mood in
                        Button {
                            reflectionMood = mood
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: mood.symbolName)
                                    .font(.title3)
                                Text(mood.title)
                                    .font(.caption2.weight(.bold))
                            }
                            .foregroundStyle(reflectionMood == mood ? Color.appTextPrimary : Color.appTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(reflectionMood == mood ? Color.appPrimary.opacity(0.35) : Color.appSurface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                TextField("Optional one-line note", text: $reflectionNote)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appSurface)
                    )
                    .foregroundStyle(Color.appTextPrimary)

                VStack(spacing: 10) {
                    PrimaryPressButton(title: "Save to journal") {
                        saveReflection()
                    }
                    .disabled(reflectionMood == nil)
                    .opacity(reflectionMood == nil ? 0.45 : 1)

                    Button("Skip") {
                        reflectionSaved = true
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(minHeight: 44)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardChrome(cornerRadius: 18)
        .padding(.horizontal, 16)
    }

    private func saveReflection() {
        guard let mood = reflectionMood else { return }
        userData.addDiaryEntry(mood: mood, note: reflectionNote, challengeTitle: challengeTitle)
        reflectionSaved = true
    }

    @ViewBuilder
    private var milestoneBanner: some View {
        if showMilestoneBanner {
            Text("Five journeys complete — steady explorer!")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppChrome.primaryButtonFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, 16)
                .offset(y: bannerOffset)
                .animation(.easeInOut(duration: 2), value: bannerOffset)
        }
    }

    private func statRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func animateEntrance() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for step in 1...min(3, stars) {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.22) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        revealedStars = step
                    }
                }
            }
        }
        if showMilestoneBanner {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 2)) {
                    bannerOffset = 0
                }
            }
        }
    }
}
