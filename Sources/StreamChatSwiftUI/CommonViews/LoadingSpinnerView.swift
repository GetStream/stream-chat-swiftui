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

/// A circular spinner badge used as a loading or progress indicator.
///
/// Renders a white circular badge with a track circle and accent arc.
///
/// - When ``progress`` is `nil` the arc rotates continuously (indeterminate).
/// - When ``progress`` is set (0…1) the arc length reflects the value (determinate).
public struct LoadingSpinnerView: View {
    @Injected(\.colors) private var colors

    let size: CGFloat
    let bordered: Bool
    let progress: Double?

    @State private var isAnimating = false

    /// Creates a loading spinner.
    /// - Parameters:
    ///   - size: The diameter of the badge.
    ///   - bordered: Whether to draw a white border ring outside the badge.
    ///   - progress: `nil` for an indeterminate spinner, or a value in 0…1 for determinate progress.
    public init(size: CGFloat, bordered: Bool = false, progress: Double? = nil) {
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

            if let progress {
                Circle()
                    .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                    .stroke(
                        Color(colors.accentPrimary),
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .frame(width: spinnerDiameter, height: spinnerDiameter)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            } else {
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(
                        Color(colors.accentPrimary),
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .frame(width: spinnerDiameter, height: spinnerDiameter)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
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

/// A circular badge shown when an attachment upload or download fails.
///
/// Renders a red circle with a white border and a retry (counterclockwise arrow)
/// icon centered inside. Matches the Figma "Retry Badge" spec: 32×32, 2 pt white
/// border, 16×16 icon.
public struct RetryBadgeView: View {
    @Injected(\.colors) private var colors

    private let size: CGFloat = 32
    private let iconSize: CGFloat = 16
    private let borderWidth: CGFloat = 2

    public init() {}

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(colors.accentError))
                .overlay(
                    Circle()
                        .inset(by: -borderWidth / 2)
                        .stroke(Color(colors.backgroundCoreElevation0), lineWidth: borderWidth)
                )
            Image(systemName: "arrow.trianglehead.clockwise.rotate.90")
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .font(Font.system(size: iconSize, weight: .bold))
                .foregroundColor(Color(colors.backgroundCoreElevation0))
        }
        .frame(width: size, height: size)
        .accessibilityIdentifier("RetryBadgeView")
    }
}
