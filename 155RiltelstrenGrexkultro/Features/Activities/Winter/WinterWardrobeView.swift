//
//  WinterWardrobeView.swift
//  155RiltelstrenGrexkultro
//

import Combine
import SwiftUI

private struct BucketFrameKey: PreferenceKey {
    static var defaultValue: [WardrobeLayer: CGRect] = [:]

    static func reduce(value: inout [WardrobeLayer: CGRect], nextValue: () -> [WardrobeLayer: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct WinterWardrobeView: View {
    @EnvironmentObject private var userData: UserData
    @EnvironmentObject private var activitiesNav: ActivitiesNavigationStore

    @StateObject private var viewModel: WinterWardrobeViewModel
    @State private var showOutcome = false
    @State private var outcomeStars = 1
    @State private var packingLine = ""
    @State private var spreadLine = ""
    @State private var milestone = false
    @State private var activeDrag: WardrobePiece?
    @State private var dragTranslation: CGSize = .zero
    @State private var bucketFrames: [WardrobeLayer: CGRect] = [:]

    init(difficulty: ActivityDifficulty) {
        _viewModel = StateObject(wrappedValue: WinterWardrobeViewModel(difficulty: difficulty))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Winter Wardrobe Wizard")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTextPrimary)

                Text("Drag pieces from the carousel into each layer slot. Fill every layer to finish.")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Trip templates")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    ForEach(WinterTripTemplate.allCases) { tpl in
                        Button {
                            viewModel.applyTripTemplate(tpl)
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: tpl == .cityDay ? "building.2.fill" : "figure.hiking")
                                    .foregroundStyle(Color.appAccent)
                                    .frame(width: 44, height: 44)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tpl.title)
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                    Text(tpl.blurb)
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                Text("Apply")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.appPrimary)
                            }
                            .padding(12)
                            .appCardChrome(cornerRadius: 14)
                        }
                        .buttonStyle(.plain)
                    }
                }

                GeometryReader { geo in
                    let tileWidth = max(120, (geo.size.width - 48) / CGFloat(max(viewModel.tray.count, 1)))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.tray) { piece in
                                carouselCell(piece, width: tileWidth)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                .frame(height: 140)

                VStack(spacing: 12) {
                    ForEach(WardrobeLayer.allCases) { layer in
                        bucket(layer: layer)
                    }
                }
                .onPreferenceChange(BucketFrameKey.self) { value in
                    bucketFrames = value
                }

                PrimaryPressButton(title: viewModel.isReadyToFinish ? "Seal packing list" : "Cover all layers to continue") {
                    presentOutcome()
                }
                .disabled(!viewModel.isReadyToFinish)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
        .fullScreenCover(isPresented: $showOutcome) {
            ChallengeOutcomeView(
                stars: outcomeStars,
                headline: "Packing blueprint ready",
                speedLabel: packingLine,
                diversityLabel: spreadLine,
                showMilestoneBanner: milestone,
                challengeTitle: ChallengeId.winterWardrobe.title,
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

    private func bucket(layer: WardrobeLayer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(layer.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)

            let items = viewModel.slots[layer] ?? []
            VStack(alignment: .leading, spacing: 6) {
                if items.isEmpty {
                    Text("Drop items here")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(12)
                } else {
                    ForEach(items) { piece in
                        HStack {
                            Image(systemName: piece.symbol)
                                .foregroundStyle(Color.appAccent)
                                .frame(width: 44, height: 44)
                            Text(piece.title)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                            Button {
                                viewModel.remove(piece: piece, from: layer)
                            } label: {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundStyle(Color.appPrimary)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppChrome.surfaceFill)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.75)
                                )
                                .compactCardShadow()
                        )
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    AppChrome.elevatedPlate(cornerRadius: 16)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.appAccent.opacity(0.35), lineWidth: 1.2)
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: BucketFrameKey.self,
                            value: [layer: proxy.frame(in: .global)]
                        )
                    }
                }
            }
        }
    }

    private func carouselCell(_ piece: WardrobePiece, width: CGFloat) -> some View {
        let isDragging = activeDrag?.id == piece.id
        return VStack(spacing: 6) {
            Image(systemName: piece.symbol)
                .font(.title2)
                .foregroundStyle(Color.appPrimary)
            Text(piece.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(width: width, height: 110)
        .appCardChrome(cornerRadius: 16)
        .scaleEffect(isDragging ? 1.04 : 1)
        .offset(isDragging ? dragTranslation : .zero)
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    if activeDrag == nil { activeDrag = piece }
                    guard activeDrag?.id == piece.id else { return }
                    dragTranslation = value.translation
                }
                .onEnded { value in
                    defer {
                        activeDrag = nil
                        dragTranslation = .zero
                    }
                    guard activeDrag?.id == piece.id else { return }
                    let endPoint = value.location
                    if let target = matchingLayer(for: endPoint) {
                        viewModel.drop(piece, into: target)
                    }
                }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.72), value: isDragging)
    }

    private func matchingLayer(for point: CGPoint) -> WardrobeLayer? {
        bucketFrames.first(where: { $0.value.contains(point) })?.key
    }

    private func presentOutcome() {
        let result = viewModel.outcome()
        outcomeStars = result.stars
        packingLine = result.packingLabel
        spreadLine = "Layer spread \(result.spread)/3"

        let before = userData.records.count
        userData.recordChallengeCompletion(
            challengeId: ChallengeId.winterWardrobe.rawValue,
            title: ChallengeId.winterWardrobe.title,
            starsEarned: result.stars,
            summaryLine: result.summary,
            durationSeconds: result.duration,
            uniquenessPoints: result.spread
        )
        milestone = before < 5 && userData.records.count >= 5
        showOutcome = true
    }
}
