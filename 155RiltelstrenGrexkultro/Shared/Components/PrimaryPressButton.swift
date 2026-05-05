//
//  PrimaryPressButton.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

struct PrimaryPressButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppChrome.primaryButtonFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.28), Color.white.opacity(0.05)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.38), radius: 10, x: 0, y: 5)
                        .shadow(color: Color.appPrimary.opacity(0.35), radius: 14, x: 0, y: 8)
                )
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryPressButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.medium))
                .foregroundStyle(Color.appAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appSurface.opacity(0.65),
                                    Color.appBackground.opacity(0.45)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.appAccent.opacity(0.55),
                                            Color.appAccent.opacity(0.18)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 5)
                        .subtleGlowShadow()
                )
        }
        .buttonStyle(.plain)
    }
}
