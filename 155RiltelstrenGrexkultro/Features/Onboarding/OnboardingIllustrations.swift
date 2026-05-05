//
//  OnboardingIllustrations.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

struct OnboardingMountainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.42))
        path.addLine(to: CGPoint(x: w * 0.52, y: h * 0.62))
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.28))
        path.addLine(to: CGPoint(x: w, y: h * 0.55))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}

struct OnboardingWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: h * 0.55))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.33, y: h * 0.38),
            control: CGPoint(x: w * 0.16, y: h * 0.22)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.66, y: h * 0.48),
            control: CGPoint(x: w * 0.5, y: h * 0.72)
        )
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.35),
            control: CGPoint(x: w * 0.84, y: h * 0.18)
        )
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

struct OnboardingSparkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        for i in 0..<8 {
            let a = CGFloat(i) / 8 * .pi * 2
            let inner = r * 0.35
            let outer = r
            let p1 = CGPoint(x: c.x + cos(a) * inner, y: c.y + sin(a) * inner)
            let p2 = CGPoint(x: c.x + cos(a + .pi / 8) * outer, y: c.y + sin(a + .pi / 8) * outer)
            if i == 0 {
                path.move(to: p1)
            } else {
                path.addLine(to: p1)
            }
            path.addLine(to: p2)
        }
        path.closeSubpath()
        return path
    }
}
