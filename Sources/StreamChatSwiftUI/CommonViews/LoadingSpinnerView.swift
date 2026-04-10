//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Predefined sizes for ``LoadingSpinnerView``.
public enum LoadingSpinnerSize: Sendable {
    @MainActor public static var large: CGFloat = 32
    @MainActor public static var medium: CGFloat = 24
    @MainActor public static var small: CGFloat = 20
    @MainActor public static var extraSmall: CGFloat = 16
}

/// A circular spinner badge used as a loading indicator over media content.
///
/// Renders a white circular badge with a border and an animated arc spinner
/// inside. The spinner consists of a light gray track circle with a blue
/// accent arc that rotates continuously.
public struct LoadingSpinnerView: View {
    @Injected(\.colors) private var colors

    let size: CGFloat
    let bordered: Bool

    @State private var isAnimating = false

    public init(size: CGFloat, bordered: Bool) {
        self.size = size
        self.bordered = bordered
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(colors.backgroundCoreElevation0))
                .overlay(
                    Circle()
                        .inset(by: -1)
                        .stroke(colors.backgroundCoreElevation0.toColor, lineWidth: bordered ? 2 : 0)
                )
            Circle()
                .stroke(Color(colors.borderCoreDefault), lineWidth: strokeWidth)
                .frame(width: spinnerDiameter, height: spinnerDiameter)
            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(
                    Color(colors.accentPrimary),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: spinnerDiameter, height: spinnerDiameter)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1).repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .frame(width: size, height: size)
        .onAppear { isAnimating = true }
        .accessibilityIdentifier("LoadingSpinnerView")
    }

    /// Diameter of the spinner arc, inset from the badge border.
    private var spinnerDiameter: CGFloat {
        size - 2
    }

    /// Stroke width of the arc, scaled proportionally to the badge size.
    private var strokeWidth: CGFloat {
        max(size * 3.0 / 32.0, 1.5)
    }
}

/// A circular spinner badge used as a deterministic upload progress indicator.
///
/// Visually identical to ``LoadingSpinnerView`` but renders a determinate
/// progress arc from 0 to 1 instead of an infinite spinning animation.
public struct UploadProgressSpinnerView: View {
    @Injected(\.colors) private var colors

    let size: CGFloat
    let bordered: Bool
    let progress: Double

    public init(size: CGFloat, bordered: Bool = false, progress: Double) {
        self.size = size
        self.bordered = bordered
        self.progress = progress
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(colors.backgroundCoreElevation0))
                .overlay(
                    Circle()
                        .inset(by: -1)
                        .stroke(colors.backgroundCoreElevation0.toColor, lineWidth: bordered ? 2 : 0)
                )
            Circle()
                .stroke(Color(colors.borderCoreDefault), lineWidth: strokeWidth)
                .frame(width: spinnerDiameter, height: spinnerDiameter)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(
                    Color(colors.accentPrimary),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: spinnerDiameter, height: spinnerDiameter)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .frame(width: size, height: size)
        .accessibilityIdentifier("UploadProgressSpinnerView")
    }

    private var spinnerDiameter: CGFloat {
        size - 2
    }

    private var strokeWidth: CGFloat {
        max(size * 3.0 / 32.0, 1.5)
    }
}
