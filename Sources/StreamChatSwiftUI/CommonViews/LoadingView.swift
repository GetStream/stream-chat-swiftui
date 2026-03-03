//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Simple loading view with a progress indicator.
public struct LoadingView: View {
    public var body: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

/// A circular spinner badge used as a loading indicator over media content.
///
/// Renders a white circular badge with a border and an animated arc spinner
/// inside. The spinner consists of a light gray track circle with a blue
/// accent arc that rotates continuously.
///
/// Matches the **Loading Badge** component from the design system.
public struct LoadingSpinnerView: View {
    @Injected(\.colors) private var colors

    let size: CGFloat

    @State private var isAnimating = false

    public init(size: CGFloat = 32) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(colors.backgroundElevationElevation0))
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
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

/// Loading view showing redacted channel list data.
public struct RedactedLoadingView<Factory: ViewFactory>: View {
    public var factory: Factory

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                factory.makeChannelListTopView(
                    options: ChannelListTopViewOptions(
                        searchText: .constant("")
                    )
                )

                LazyVStack(spacing: 0) {
                    ForEach(0..<20) { _ in
                        RedactedChannelCell()
                            .shimmering()
                        Divider()
                    }
                }
            }
        }
        .accessibilityIdentifier("RedactedLoadingView")
    }
}

struct RedactedChannelCell: View {
    @Injected(\.colors) private var colors

    private let circleSize: CGFloat = 48

    private var redactedColor: Color {
        Color(colors.disabledColorForColor(colors.text))
    }

    public var body: some View {
        HStack(alignment: .center) {
            Circle()
                .fill(redactedColor)
                .frame(width: circleSize, height: circleSize)

            VStack(alignment: .leading) {
                RedactedRectangle(width: 70, redactedColor: redactedColor)

                HStack {
                    RedactedRectangle(redactedColor: redactedColor)
                    RedactedRectangle(width: 50, redactedColor: redactedColor)
                }
            }
        }
        .padding(.all, 8)
    }
}

struct RedactedRectangle: View {
    var width: CGFloat?
    var redactedColor: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(redactedColor)
            .frame(width: width, height: 16)
    }
}
