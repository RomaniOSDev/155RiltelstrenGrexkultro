//
//  DiscoverDecorations.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

struct DiscoverHorizonBackdrop: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                DiscoverHillPath()
                    .fill(Color.appPrimary.opacity(0.22))
                    .frame(width: w, height: h)
                    .position(x: w / 2, y: h * 0.72)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appAccent.opacity(0.95), Color.appPrimary.opacity(0.35)],
                            center: .center,
                            startRadius: 4,
                            endRadius: h * 0.38
                        )
                    )
                    .frame(width: h * 0.62, height: h * 0.62)
                    .position(x: w * 0.22, y: h * 0.42)

                DiscoverCloudBlob()
                    .fill(Color.appSurface.opacity(0.55))
                    .frame(width: w * 0.32, height: h * 0.22)
                    .position(x: w * 0.72, y: h * 0.38)

                DiscoverCloudBlob()
                    .fill(Color.appSurface.opacity(0.4))
                    .frame(width: w * 0.24, height: h * 0.16)
                    .position(x: w * 0.88, y: h * 0.52)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipped()
    }
}

private struct DiscoverHillPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: h * 0.35))
        path.addQuadCurve(to: CGPoint(x: w * 0.45, y: h * 0.2), control: CGPoint(x: w * 0.22, y: h * 0.05))
        path.addQuadCurve(to: CGPoint(x: w, y: h * 0.4), control: CGPoint(x: w * 0.72, y: h * 0.12))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

private struct DiscoverCloudBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let cx = w / 2
        let cy = h / 2
        path.addEllipse(in: CGRect(x: cx - w * 0.35, y: cy - h * 0.25, width: w * 0.45, height: h * 0.5))
        path.addEllipse(in: CGRect(x: cx - w * 0.08, y: cy - h * 0.35, width: w * 0.5, height: h * 0.55))
        path.addEllipse(in: CGRect(x: cx + w * 0.12, y: cy - h * 0.2, width: w * 0.38, height: h * 0.45))
        return path
    }
}

struct DiscoverDetailHeroOrb: View {
    let symbolName: String

    var body: some View {
        ZStack {
            DiscoverGlowRing()
                .stroke(Color.appAccent.opacity(0.55), lineWidth: 3)
                .frame(width: 120, height: 120)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, Color.appPrimary.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 96, height: 96)
                .overlay {
                    Image(systemName: symbolName)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(Color.appAccent)
                        .symbolRenderingMode(.hierarchical)
                }
        }
        .accessibilityHidden(true)
    }
}

private struct DiscoverGlowRing: Shape {
    func path(in rect: CGRect) -> Path {
        Path(ellipseIn: rect)
    }
}
