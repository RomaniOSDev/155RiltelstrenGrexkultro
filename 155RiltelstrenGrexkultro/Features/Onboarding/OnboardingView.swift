//
//  OnboardingView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var userData: UserData
    @State private var page = 0
    @State private var shapeShown = false
    @State private var showLetsGo = false

    private let heroCorner: CGFloat = 26

    var body: some View {
        TabView(selection: $page) {
            onboardingPage(
                stepLabel: "01 · Outlook",
                title: "Adventurous Outlook",
                bodyText: "Pair bright skies with bold outdoor plans and capture highlights as you roam.",
                gradientColors: [
                    Color.appPrimary.opacity(0.95),
                    Color.appPrimary.opacity(0.52),
                    Color.appAccent.opacity(0.42)
                ],
                illustration: { OnboardingMountainShape() }
            )
            .tag(0)

            onboardingPage(
                stepLabel: "02 · Calm",
                title: "Everyday Calm",
                bodyText: "Gentle rhythms in shifting weather help you stay grounded between plans.",
                gradientColors: [
                    Color.appAccent.opacity(0.92),
                    Color.appAccent.opacity(0.45),
                    Color.appPrimary.opacity(0.35)
                ],
                illustration: { OnboardingWaveShape() }
            )
            .tag(1)

            onboardingPage(
                stepLabel: "03 · Flow",
                title: "Spontaneous Planning",
                bodyText: "Quick reads on conditions let you pivot and still enjoy the day.",
                gradientColors: [
                    Color.appPrimary.opacity(0.88),
                    Color.appAccent.opacity(0.5),
                    Color.appPrimary.opacity(0.4)
                ],
                illustration: { OnboardingSparkShape() },
                showAction: true
            )
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .tint(Color.appAccent)
        .appScreenBackground()
        .onChange(of: page) { newValue in
            shapeShown = false
            showLetsGo = false
            withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
                shapeShown = true
            }
            if newValue == 2 {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(0.32)) {
                    showLetsGo = true
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
                shapeShown = true
            }
        }
    }

    private func onboardingPage<S: Shape>(
        stepLabel: String,
        title: String,
        bodyText: String,
        gradientColors: [Color],
        @ViewBuilder illustration: () -> S,
        showAction: Bool = false
    ) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                Text(stepLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appAccent)
                    .tracking(0.6)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.appSurface.opacity(0.55))
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )
                    .padding(.top, 8)
                    .opacity(shapeShown ? 1 : 0)
                    .offset(y: shapeShown ? 0 : 8)
                    .animation(.spring(response: 0.45, dampingFraction: 0.82), value: shapeShown)

                illustrationStage(shape: illustration(), colors: gradientColors)

                VStack(spacing: 14) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.center)
                        .shadow(color: Color.black.opacity(0.25), radius: 6, y: 2)

                    Text(bodyText)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 22)
                .frame(maxWidth: .infinity)
                .appCardChrome(cornerRadius: 22)
                .padding(.horizontal, 16)
                .scaleEffect(shapeShown ? 1 : 0.94)
                .opacity(shapeShown ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.78).delay(0.06), value: shapeShown)

                if showAction {
                    PrimaryPressButton(title: "Let's Go") {
                        userData.markOnboardingSeen()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .opacity(showLetsGo ? 1 : 0)
                    .offset(y: showLetsGo ? 0 : 12)
                    .animation(.spring(response: 0.48, dampingFraction: 0.82), value: showLetsGo)
                }

                Spacer(minLength: 40)
            }
            .padding(.top, 20)
        }
    }

    private func illustrationStage<S: Shape>(shape: S, colors: [Color]) -> some View {
        let fill = LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        return ZStack {
            AppChrome.heroBackground(cornerRadius: heroCorner)

            shape
                .fill(fill)
                .overlay(
                    shape.stroke(AppChrome.cardBorder, lineWidth: 1.35)
                )
                .padding(.horizontal, 36)
                .padding(.vertical, 28)
                .scaleEffect(shapeShown ? 1 : 0.75)
                .opacity(shapeShown ? 1 : 0)
                .animation(.spring(response: 0.52, dampingFraction: 0.72), value: shapeShown)
        }
        .frame(height: 200)
        .padding(.horizontal, 16)
        .clipShape(RoundedRectangle(cornerRadius: heroCorner, style: .continuous))
        .shadow(color: Color.black.opacity(0.32), radius: 16, x: 0, y: 10)
        .shadow(color: Color.appAccent.opacity(0.14), radius: 22, x: 0, y: 12)
    }
}
