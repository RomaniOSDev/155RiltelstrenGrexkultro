//
//  CustomTabBarShape.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

struct CustomTabBarOutline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let corner: CGFloat = 22
        let notchDepth: CGFloat = 18
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: corner, y: 0))
        path.addLine(to: CGPoint(x: w * 0.34, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: notchDepth),
            control: CGPoint(x: w * 0.42, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.66, y: 0),
            control: CGPoint(x: w * 0.58, y: 0)
        )
        path.addLine(to: CGPoint(x: w - corner, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: w, y: corner),
            control: CGPoint(x: w, y: 0)
        )
        path.addLine(to: CGPoint(x: w, y: h - corner))
        path.addQuadCurve(
            to: CGPoint(x: w - corner, y: h),
            control: CGPoint(x: w, y: h)
        )
        path.addLine(to: CGPoint(x: corner, y: h))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h - corner),
            control: CGPoint(x: 0, y: h)
        )
        path.addLine(to: CGPoint(x: 0, y: corner))
        path.addQuadCurve(
            to: CGPoint(x: corner, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        path.closeSubpath()
        return path
    }
}

enum MainTab: Int, CaseIterable, Hashable {
    case home = 0
    case discover = 1
    case activities = 2
    case profile = 3

    var title: String {
        switch self {
        case .home: return "Home"
        case .discover: return "Discover"
        case .activities: return "Activities"
        case .profile: return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "sparkles"
        case .activities: return "figure.run"
        case .profile: return "person.crop.circle"
        }
    }
}

struct CustomTabBarView: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selection = tab
                    }
                } label: {
                    ZStack {
                        if selection == tab {
                            Circle()
                                .fill(Color.appAccent.opacity(0.25))
                                .frame(width: 48, height: 48)
                                .blur(radius: 10)
                        }
                        VStack(spacing: 3) {
                            Image(systemName: tab.systemImage)
                                .font(.system(size: 19, weight: .semibold))
                                .shadow(color: selection == tab ? Color.appAccent.opacity(0.5) : .clear, radius: 6, y: 2)
                            Text(tab.title)
                                .font(.caption2.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.55)
                        }
                    }
                    .foregroundStyle(selection == tab ? Color.appAccent : Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            ZStack {
                CustomTabBarOutline()
                    .fill(AppChrome.tabBarFill)
                CustomTabBarOutline()
                    .stroke(AppChrome.tabBarStroke, lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.48), radius: 28, x: 0, y: -12)
            .shadow(color: Color.appAccent.opacity(0.12), radius: 20, x: 0, y: -6)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
        .accessibilityElement(children: .contain)
    }
}
