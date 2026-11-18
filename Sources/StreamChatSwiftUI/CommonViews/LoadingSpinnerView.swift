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
    let isOnInverseBackground: Bool

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
        isOnInverseBackground = false
    }

    /// Creates an indeterminate spinner for an inverse background, such as a snack bar. It draws only the track and
    /// the arc, in the color of text on an inverse background.
    init(sizeOnInverseBackground size: CGFloat) {
        self.size = size
        bordered = false
        progress = nil
        isOnInverseBackground = true
    }

    public var body: some View {
        ZStack {
            if !isOnInverseBackground {
                Circle()
                    .fill(Color(colors.backgroundCoreElevation0))
                    .overlay(
                        Circle()
                            .inset(by: -1)
                            .stroke(colors.backgroundCoreElevation0.toColor, lineWidth: bordered ? 2 : 0)
                    )
            }
            Circle()
                .stroke(trackColor, lineWidth: strokeWidth)
                .frame(width: spinnerDiameter, height: spinnerDiameter)

            if let progress {
                Circle()
                    .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                    .stroke(
                        arcColor,
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .frame(width: spinnerDiameter, height: spinnerDiameter)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            } else {
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(
                        arcColor,
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

    private var trackColor: Color {
        isOnInverseBackground ? Color(colors.textOnInverse).opacity(0.3) : Color(colors.borderCoreDefault)
    }

    private var arcColor: Color {
        Color(isOnInverseBackground ? colors.textOnInverse : colors.accentPrimary)
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
