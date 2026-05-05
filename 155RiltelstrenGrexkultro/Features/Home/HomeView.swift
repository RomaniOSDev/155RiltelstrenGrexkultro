//
//  HomeView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userData: UserData
    @EnvironmentObject private var tabCoordinator: MainTabCoordinator

    @State private var heroShown = false

    private let rowSpacing: CGFloat = 12
    private let statRowHeight: CGFloat = 112
    private let utilityRowHeight: CGFloat = 132

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: rowSpacing) {
                    heroWidget

                    decorativeStrip

                    scenarioWidget

                    HStack(alignment: .top, spacing: rowSpacing) {
                        statTile(
                            value: "\(userData.collectedStars)",
                            icon: "star.fill",
                            tint: Color.appPrimary
                        )
                        statTile(
                            value: "\(userData.discoverStreak)",
                            icon: "flame.fill",
                            tint: Color.orange.opacity(0.95)
                        )
                    }

                    nextRouteWidget

                    journalWidget

                    HStack(alignment: .top, spacing: rowSpacing) {
                        remindersWidget
                            .frame(maxWidth: .infinity, minHeight: utilityRowHeight, maxHeight: utilityRowHeight)
                        settingsWidget
                            .frame(maxWidth: .infinity, minHeight: utilityRowHeight, maxHeight: utilityRowHeight)
                    }

                    achievementsWidget
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .padding(.bottom, 100)
            }
            .appScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.appAccent)
                        Text("Home")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                    }
                }
            }
            .appNavigationChrome()
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                heroShown = true
            }
        }
    }

    // MARK: - Hero

    private var heroWidget: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appPrimary.opacity(0.5),
                    Color.appSurface.opacity(0.85),
                    Color.appBackground.opacity(0.25),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 0) {
                VStack(spacing: 14) {
                    Image(systemName: greetingIcon)
                        .font(.system(size: 44))
                        .foregroundStyle(.linearGradient(colors: [.white, Color.appAccent], startPoint: .top, endPoint: .bottom))
                        .symbolRenderingMode(.hierarchical)
                        .shadow(color: Color.appAccent.opacity(0.35), radius: 10, y: 2)

                    Text(greetingWord)
                        .font(.title3.bold())
                        .foregroundStyle(Color.appTextPrimary)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 10) {
                        iconCircleButton(symbol: "sparkles", tint: Color.appAccent) {
                            tabCoordinator.open(.discover)
                        }
                        iconCircleButton(symbol: "figure.run", tint: Color.appPrimary) {
                            tabCoordinator.open(.activities)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                ZStack {
                    Image(systemName: "sun.horizon.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.appAccent.opacity(0.2))
                    Image(systemName: "camera.macro")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.appPrimary.opacity(0.4))
                }
                .frame(width: 64, height: 100)
                .clipped()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, minHeight: 156, maxHeight: 156)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.appAccent.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.38), radius: 18, x: 0, y: 12)
        .subtleGlowShadow()
        .scaleEffect(heroShown ? 1 : 0.96)
        .opacity(heroShown ? 1 : 0)
    }

    private var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "sunrise.fill"
        case 12..<17: return "sun.max.fill"
        case 17..<22: return "sun.horizon.fill"
        default: return "moon.stars.fill"
        }
    }

    private var greetingWord: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Hello"
        case 17..<22: return "Evening"
        default: return "Night"
        }
    }

    private func iconCircleButton(symbol: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(tint.opacity(0.85))
                        .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 4)
                )
                .shadow(color: tint.opacity(0.35), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(symbol == "sparkles" ? "Discover" : "Activities")
    }

    // MARK: - Decorative strip

    private var decorativeStrip: some View {
        HStack(spacing: 0) {
            stripGlyph("leaf.fill", .green.opacity(0.75))
            stripGlyph("camera.fill", Color.appAccent)
            stripGlyph("figure.walk", Color.appPrimary)
            stripGlyph("cloud.sun.fill", .cyan.opacity(0.85))
            stripGlyph("mountain.2.fill", Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .clipped()
        .appCardChrome(cornerRadius: 20)
    }

    private func stripGlyph(_ name: String, _ color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 20))
            .foregroundStyle(color)
            .symbolRenderingMode(.hierarchical)
            .frame(minWidth: 0, maxWidth: .infinity)
    }

    // MARK: - Scenario

    private var scenarioWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .font(.title2)
                    .foregroundStyle(Color.appAccent)
                Spacer(minLength: 0)
                Button {
                    tabCoordinator.open(.discover)
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.appPrimary)
                }
                .buttonStyle(.plain)
            }

            // Horizontal content must not widen the screen: bounded width + clip.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    scenarioOrb(nil)
                    ForEach(DayScenario.allCases) { scenario in
                        scenarioOrb(scenario)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 82)
            .clipped()

            if let s = userData.selectedScenario {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appAccent.opacity(0.8))
                    Text(s.shortTip)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardChrome(cornerRadius: 20)
    }

    private func scenarioOrb(_ scenario: DayScenario?) -> some View {
        let active = (scenario == nil && userData.selectedScenario == nil) || (scenario != nil && userData.selectedScenario == scenario)
        return Button {
            userData.setSelectedScenario(scenario)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            active
                                ? Color.appAccent.opacity(0.35)
                                : Color.appBackground.opacity(0.55)
                        )
                        .frame(width: 44, height: 44)
                    if let scenario {
                        Image(systemName: scenario.symbolName)
                            .font(.body)
                            .foregroundStyle(active ? Color.appTextPrimary : Color.appTextSecondary)
                    } else {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.body)
                            .foregroundStyle(active ? Color.appTextPrimary : Color.appTextSecondary)
                    }
                }
                Text(scenario?.title ?? "All")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: 52)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stats (equal halves)

    private func statTile(value: String, icon: String, tint: Color) -> some View {
        ZStack(alignment: .center) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(tint.opacity(0.14))

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .minimumScaleFactor(0.45)
                    .lineLimit(1)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(tint)
                    .symbolRenderingMode(.multicolor)
            }
            .padding(.horizontal, 6)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: statRowHeight, maxHeight: statRowHeight)
        .clipped()
        .appCardChrome(cornerRadius: 20)
    }

    // MARK: - Next route

    private var nextRouteWidget: some View {
        let challenge = spotlightChallenge()
        return Button {
            tabCoordinator.open(.activities)
        } label: {
            ZStack(alignment: .leading) {
                HStack {
                    Spacer(minLength: 0)
                    Image(systemName: challenge.map(challengeIcon) ?? "map")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.appPrimary.opacity(0.1))
                        .accessibilityHidden(true)
                }
                .padding(.trailing, 6)
                .allowsHitTesting(false)

                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "arrow.forward.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.appAccent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(challenge?.title ?? "Routes")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        if challenge == nil {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(Color.appPrimary)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .appCardChrome(cornerRadius: 20)
    }

    private func spotlightChallenge() -> ChallengeId? {
        for challenge in ChallengeId.allCases {
            guard userData.isUnlocked(challengeId: challenge) else { continue }
            if !userData.completedChallengeIds.contains(challenge.rawValue) {
                return challenge
            }
        }
        return nil
    }

    private func challengeIcon(_ id: ChallengeId) -> String {
        switch id {
        case .sunnyCollections: return "sun.max.fill"
        case .rainyRejuvenation: return "cloud.rain.fill"
        case .winterWardrobe: return "snowflake"
        }
    }

    // MARK: - Journal

    private var journalWidget: some View {
        HStack(alignment: .center, spacing: 10) {
            if let entry = userData.diaryEntries.first {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.28))
                        .frame(width: 56, height: 56)
                    Image(systemName: entry.mood.symbolName)
                        .font(.system(size: 26))
                        .foregroundStyle(Color.appTextPrimary)
                }
                .layoutPriority(0)

                VStack(alignment: .leading, spacing: 4) {
                    if !entry.note.isEmpty {
                        Text(entry.note)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(entry.recordedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            } else {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 34))
                    .foregroundStyle(Color.appAccent.opacity(0.35))
                    .frame(width: 52, height: 52)

                HStack(spacing: 8) {
                    ForEach(ReflectionMood.allCases) { mood in
                        Image(systemName: mood.symbolName)
                            .font(.callout)
                            .foregroundStyle(Color.appTextSecondary.opacity(0.45))
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }

            Button {
                tabCoordinator.open(.profile)
            } label: {
                Image(systemName: "chart.xyaxis.line")
                    .font(.body)
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Color.appSurface))
            }
            .buttonStyle(.plain)
            .layoutPriority(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardChrome(cornerRadius: 20)
    }

    // MARK: - Reminders & settings

    private var remindersWidget: some View {
        VStack(spacing: 10) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color.appAccent)
                .symbolRenderingMode(.hierarchical)

            HStack(spacing: 6) {
                reminderGlyph("photo.on.rectangle.angled", userData.reminderAlbumEnabled)
                reminderGlyph("wind", userData.reminderBreathEnabled)
                reminderGlyph("shippingbox.fill", userData.reminderPackEnabled)
            }
            .frame(maxWidth: .infinity)

            Text(Self.reminderTimeString(hour: userData.reminderHour, minute: userData.reminderMinute))
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appCardChrome(cornerRadius: 20)
    }

    private func reminderGlyph(_ name: String, _ on: Bool) -> some View {
        Image(systemName: name)
            .font(.callout)
            .foregroundStyle(on ? Color.appAccent : Color.appTextSecondary.opacity(0.35))
            .frame(minWidth: 0, maxWidth: .infinity)
    }

    private var settingsWidget: some View {
        NavigationLink {
            SettingsView()
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "gearshape.2.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.appPrimary)
                    .symbolRenderingMode(.hierarchical)
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.appAccent.opacity(0.65))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(12)
            .appCardChrome(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }

    private static func reminderTimeString(hour: Int, minute: Int) -> String {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = hour
        c.minute = minute
        guard let d = Calendar.current.date(from: c) else { return "\(hour):\(minute)" }
        return d.formatted(date: .omitted, time: .shortened)
    }

    // MARK: - Achievements (fixed circles, never exceeds width)

    private var achievementsWidget: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            achievementOrb(symbol: "map.fill", done: userData.hasSeasonedExplorerAchievement, tint: Color.appPrimary)
            Spacer(minLength: 0)
            achievementOrb(symbol: "cloud.sun.fill", done: userData.hasWeatherMixAchievement, tint: .cyan)
            Spacer(minLength: 0)
            achievementOrb(symbol: "sparkles", done: userData.hasDiscoverStreak7, tint: Color.appAccent)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .appCardChrome(cornerRadius: 20)
    }

    private func achievementOrb(symbol: String, done: Bool, tint: Color) -> some View {
        ZStack {
            Circle()
                .fill(done ? tint.opacity(0.25) : Color.appBackground.opacity(0.45))
                .frame(width: 50, height: 50)
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(done ? tint : Color.appTextSecondary.opacity(0.4))
                .symbolRenderingMode(.hierarchical)
        }
        .overlay(
            Circle()
                .strokeBorder(tint.opacity(done ? 0.55 : 0.14), lineWidth: 2)
        )
    }
}
