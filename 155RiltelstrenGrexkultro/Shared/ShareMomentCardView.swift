//
//  ShareMomentCardView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI
import UIKit

struct ShareMomentCardView: View {
    let scenarioTitle: String
    let scenarioTip: String
    let accentLine: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appPrimary.opacity(0.25),
                    Color.appBackground,
                    Color.appSurface.opacity(0.95),
                    Color.appBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            LinearGradient(
                colors: [Color.white.opacity(0.08), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            VStack(spacing: 16) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.appAccent)
                    .symbolRenderingMode(.multicolor)
                    .shadow(color: Color.appAccent.opacity(0.45), radius: 14, y: 6)

                Text("Today's rhythm")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)

                Text(scenarioTitle)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)

                Text(scenarioTip)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Text(accentLine)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(28)
        }
        .frame(width: 360, height: 480)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.appAccent.opacity(0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
}

enum ShareMomentCardRender {
    @MainActor
    static func pngData(scenario: DayScenario?, accentLine: String) -> Data? {
        let s = scenario ?? .clear
        let renderer = ImageRenderer(
            content: ShareMomentCardView(
                scenarioTitle: s.title,
                scenarioTip: s.shortTip,
                accentLine: accentLine
            )
        )
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage?.pngData()
    }
}
