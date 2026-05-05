//
//  DiscoverView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI
import UIKit

private struct DiscoverSuggestion: Identifiable {
    var id: String { title }
    let title: String
    let blurb: String
    let symbol: String
    let tag: String
    let vibe: String
    let scenarios: Set<DayScenario>
}

struct DiscoverView: View {
    @EnvironmentObject private var userData: UserData
    @State private var selected: DiscoverSuggestion?
    @State private var heroAppeared = false
    @State private var isSharePresented = false
    @State private var sharePayload: [Any] = []

    private let items: [DiscoverSuggestion] = [
        DiscoverSuggestion(
            title: "Golden Hour Stroll",
            blurb: "Soft light and mild breeze — ideal for a waterfront walk with light layers.",
            symbol: "sun.horizon.fill",
            tag: "Outdoor",
            vibe: "Warm glow",
            scenarios: [.clear, .heat]
        ),
        DiscoverSuggestion(
            title: "Misty Rooftop Sketch",
            blurb: "Low clouds and drizzle pair well with short outdoor bursts and warm drink breaks.",
            symbol: "cloud.fog.fill",
            tag: "Mixed",
            vibe: "Soft focus",
            scenarios: [.rain, .windy]
        ),
        DiscoverSuggestion(
            title: "Crisp Trail Sprint",
            blurb: "Cool dry air supports quick cardio; add gloves if wind picks up.",
            symbol: "wind",
            tag: "Outdoor",
            vibe: "Energetic",
            scenarios: [.clear, .windy, .coldSnap]
        ),
        DiscoverSuggestion(
            title: "Indoor Bloom Session",
            blurb: "Stormy windows turn focus to balcony herbs and mindful breathing routines.",
            symbol: "leaf.fill",
            tag: "Indoor",
            vibe: "Calm nook",
            scenarios: [.rain, .windy, .coldSnap, .heat]
        ),
        DiscoverSuggestion(
            title: "Harbor Breeze Loop",
            blurb: "Steady sea air keeps you alert—choose a loop with cafes for quick warm-ups.",
            symbol: "water.waves",
            tag: "Outdoor",
            vibe: "Coastal",
            scenarios: [.windy, .clear]
        ),
        DiscoverSuggestion(
            title: "Evening Sky Watch",
            blurb: "Thin high clouds paint long gradients—perfect for a slow terrace pause.",
            symbol: "moon.stars.fill",
            tag: "Slow",
            vibe: "Twilight",
            scenarios: [.clear, .heat]
        )
    ]

    private var filteredItems: [DiscoverSuggestion] {
        guard let s = userData.selectedScenario else { return items }
        return items.filter { $0.scenarios.contains(s) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    discoverHero
                    dayScenarioStrip
                    quickSparksSection
                    curatedHeader
                    LazyVStack(spacing: 14) {
                        ForEach(filteredItems) { item in
                            discoveryCard(item)
                        }
                    }
                    if filteredItems.isEmpty {
                        Text("No picks for this scenario yet—try \"All skies\" or another state.")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(16)
                .padding(.bottom, 12)
            }
            .appScreenBackground()
            .navigationTitle("Discover")
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
            .sheet(item: $selected) { item in
                DiscoverDetailSheet(item: item)
                    .environmentObject(userData)
            }
            .onAppear {
                userData.recordDiscoverVisit()
                withAnimation(.easeOut(duration: 0.55).delay(0.05)) {
                    heroAppeared = true
                }
            }
        }
    }

    private func prepareShare() {
        let line = userData.hasDiscoverStreak7
            ? "You're on a long Discover streak—beautiful consistency."
            : "Small outdoor rituals add up—share the vibe without sharing locations."
        guard let data = ShareMomentCardRender.pngData(scenario: userData.selectedScenario, accentLine: line),
              let img = UIImage(data: data) else { return }
        sharePayload = [img]
        isSharePresented = true
    }

    private var dayScenarioStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's scenario")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    scenarioChipAll
                    ForEach(DayScenario.allCases) { scenario in
                        scenarioChip(scenario)
                    }
                }
                .padding(.vertical, 4)
            }

            if let s = userData.selectedScenario {
                Text(s.shortTip)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var scenarioChipAll: some View {
        let active = userData.selectedScenario == nil
        return Button {
            userData.setSelectedScenario(nil)
        } label: {
            Text("All skies")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(active ? Color.appTextPrimary : Color.appTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(
                            active
                                ? AnyShapeStyle(AppChrome.primaryButtonFill)
                                : AnyShapeStyle(AppChrome.surfaceFill)
                        )
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    active
                                        ? AnyShapeStyle(Color.white.opacity(0.22))
                                        : AnyShapeStyle(AppChrome.cardBorder),
                                    lineWidth: active ? 1 : 0.85
                                )
                        }
                        .shadow(
                            color: active ? Color.appPrimary.opacity(0.35) : Color.black.opacity(0.22),
                            radius: active ? 10 : 5,
                            x: 0,
                            y: active ? 5 : 3
                        )
                }
        }
        .buttonStyle(.plain)
    }

    private func scenarioChip(_ scenario: DayScenario) -> some View {
        let active = userData.selectedScenario == scenario
        return Button {
            userData.setSelectedScenario(scenario)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: scenario.symbolName)
                Text(scenario.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(active ? Color.appTextPrimary : Color.appTextSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(
                        active
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        Color.appAccent.opacity(0.42),
                                        Color.appAccent.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(AppChrome.surfaceFill)
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                active
                                    ? AnyShapeStyle(Color.appAccent.opacity(0.45))
                                    : AnyShapeStyle(AppChrome.cardBorder),
                                lineWidth: active ? 1 : 0.85
                            )
                    }
                    .shadow(
                        color: active ? Color.appAccent.opacity(0.28) : Color.black.opacity(0.22),
                        radius: active ? 8 : 5,
                        x: 0,
                        y: active ? 4 : 3
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private var discoverHero: some View {
        ZStack(alignment: .bottomLeading) {
            DiscoverHorizonBackdrop()
                .frame(height: 168)

            VStack(alignment: .leading, spacing: 8) {
                Text("Sky-led ideas")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .shadow(color: Color.appBackground.opacity(0.45), radius: 6, y: 2)

                Text("Turn today's mood into a small plan—tap any card to expand the story.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appTextPrimary.opacity(0.92))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: Color.appBackground.opacity(0.35), radius: 4, y: 1)
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppChrome.heroBackground(cornerRadius: 24)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.32), radius: 16, x: 0, y: 10)
        .shadow(color: Color.appAccent.opacity(0.14), radius: 22, x: 0, y: 12)
        .scaleEffect(heroAppeared ? 1 : 0.96)
        .opacity(heroAppeared ? 1 : 0)
        .animation(.spring(response: 0.45, dampingFraction: 0.78), value: heroAppeared)
        .accessibilityElement(children: .combine)
    }

    private var quickSparksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkle")
                    .foregroundStyle(Color.appAccent)
                Text("Quick sparks")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(filteredItems.prefix(4))) { item in
                        quickSparkTile(item)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func quickSparkTile(_ item: DiscoverSuggestion) -> some View {
        Button {
            selected = item
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: item.symbol)
                        .font(.title3)
                        .foregroundStyle(Color.appAccent)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.appPrimary.opacity(0.22)))
                    Spacer(minLength: 0)
                    Text(item.vibe)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.appPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.appPrimary.opacity(0.18)))
                }
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
            }
            .padding(14)
            .frame(width: 168, alignment: .leading)
            .appCardChrome(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private var curatedHeader: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.appPrimary)
                .frame(width: 4, height: 22)
            Text("Curated picks")
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
        }
        .padding(.top, 4)
    }

    private func discoveryCard(_ item: DiscoverSuggestion) -> some View {
        Button {
            selected = item
        } label: {
            HStack(alignment: .top, spacing: 0) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.appPrimary)
                    .frame(width: 5)
                    .padding(.vertical, 10)

                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimary.opacity(0.35), Color.appSurface.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                        Image(systemName: item.symbol)
                            .font(.title2)
                            .foregroundStyle(Color.appAccent)
                            .symbolRenderingMode(.hierarchical)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(item.tag.uppercased())
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(Color.appAccent)
                                .tracking(0.6)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.appAccent.opacity(0.16)))
                            Text(item.vibe)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .multilineTextAlignment(.leading)
                        Text(item.blurb)
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.appPrimary.opacity(0.85))
                        .frame(width: 44, height: 44)
                }
                .padding(14)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.appSurface)
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.12), Color.clear],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(AppChrome.cardBorder, lineWidth: 1)
            )
            .compactCardShadow()
            .subtleGlowShadow()
        }
        .buttonStyle(.plain)
    }
}

private struct DiscoverDetailSheet: View {
    let item: DiscoverSuggestion
    @EnvironmentObject private var userData: UserData
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 16) {
                        DiscoverDetailHeroOrb(symbolName: item.symbol)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.tag.uppercased())
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(Color.appAccent)
                                .tracking(0.5)
                            Text(item.title)
                                .font(.title3.bold())
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(3)
                                .minimumScaleFactor(0.75)
                            Text(item.vibe)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let scenario = userData.selectedScenario {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: scenario.symbolName)
                                .font(.title3)
                                .foregroundStyle(Color.appAccent)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.appPrimary.opacity(0.22)))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Scenario tip · \(scenario.title)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.appTextSecondary)
                                Text(scenario.shortTip)
                                    .font(.callout.weight(.medium))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.appAccent.opacity(0.18),
                                            Color.appSurface.opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(AppChrome.cardBorder, lineWidth: 1)
                                )
                                .compactCardShadow()
                        )
                    }

                    Text(item.blurb)
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 10) {
                        Label {
                            Text("Pack a light shell if gusts swing")
                                .font(.callout)
                                .foregroundStyle(Color.appTextPrimary)
                        } icon: {
                            Image(systemName: "tshirt.fill")
                                .foregroundStyle(Color.appPrimary)
                                .frame(width: 28)
                        }
                        Label {
                            Text("Note wind shifts before you commit to distance")
                                .font(.callout)
                                .foregroundStyle(Color.appTextPrimary)
                        } icon: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundStyle(Color.appPrimary)
                                .frame(width: 28)
                        }
                        Label {
                            Text("Pick a turn-around time before you head out")
                                .font(.callout)
                                .foregroundStyle(Color.appTextPrimary)
                        } icon: {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(Color.appPrimary)
                                .frame(width: 28)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardChrome(cornerRadius: 16)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .appScreenBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(Color.appAccent)
                }
            }
        }
    }
}
