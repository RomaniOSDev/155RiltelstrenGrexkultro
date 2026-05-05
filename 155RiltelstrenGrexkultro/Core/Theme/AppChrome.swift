//
//  AppChrome.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

/// Shared gradients, shadows, and card chrome for a consistent “elevated” dark UI.
enum AppChrome {

    static var screenGradient: LinearGradient {
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
    }

    static var screenVignette: LinearGradient {
        LinearGradient(
            colors: [Color.black.opacity(0), Color.black.opacity(0.42)],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    static var toolbarGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.97),
                Color.appSurface.opacity(0.78)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

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

    static var cardBorder: LinearGradient {
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

    static var primaryButtonFill: LinearGradient {
        LinearGradient(
            colors: [Color.appPrimary, Color.appPrimary.opacity(0.72)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var tabBarFill: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.99),
                Color.appSurface.opacity(0.86)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var tabBarStroke: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.12),
                Color.appAccent.opacity(0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Card / panel with depth + rim light.
    static func elevatedPlate(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(surfaceFill)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.38), radius: 12, x: 0, y: 7)
            .subtleGlowShadow()
    }

    /// Hero-style panel fill + rim (add `.shadow` after `clipShape` if needed).
    static func heroBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.appSurface.opacity(0.55),
                        Color.appPrimary.opacity(0.12),
                        Color.appSurface.opacity(0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(cardBorder, lineWidth: 1)
            )
    }

    /// Standalone hero with depth (no outer clip).
    static func heroPlate(cornerRadius: CGFloat) -> some View {
        heroBackground(cornerRadius: cornerRadius)
            .shadow(color: Color.black.opacity(0.32), radius: 16, x: 0, y: 10)
            .shadow(color: Color.appAccent.opacity(0.14), radius: 22, x: 0, y: 12)
    }
}

extension View {

    func appScreenBackground() -> some View {
        background {
            ZStack {
                AppChrome.screenGradient
                AppChrome.screenVignette
            }
            .ignoresSafeArea()
        }
    }

    func appToolbarChrome() -> some View {
        toolbarBackground(AppChrome.toolbarGradient, for: .navigationBar)
    }

    func appNavigationChrome() -> some View {
        toolbarBackground(AppChrome.toolbarGradient, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }

    /// Drop-in replacement for flat `Color.appSurface` cards.
    func appCardChrome(cornerRadius: CGFloat = 16) -> some View {
        background {
            AppChrome.elevatedPlate(cornerRadius: cornerRadius)
        }
    }

    func subtleGlowShadow() -> some View {
        shadow(color: Color.appAccent.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    func compactCardShadow() -> some View {
        shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 5)
    }
}
