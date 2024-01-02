//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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

/// Loading view showing redacted channel list data.
public struct RedactedLoadingView<Factory: ViewFactory>: View {

    public var factory: Factory

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                factory.makeChannelListTopView(
                    searchText: .constant("")
                )

                VStack(spacing: 0) {
                    ForEach(0..<20) { _ in
                        RedactedChannelCell()
                        Divider()
                    }
                }
                .shimmering()
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
        HStack {
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

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration = 1.5

    public func body(content: Content) -> some View {
        content
            .modifier(AnimatedMask(phase: phase).animation(
                Animation
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
            ))
            .onAppear { phase = 0.8 }
    }

    /// An animatable modifier to interpolate between `phase` values.
    struct AnimatedMask: AnimatableModifier {
        var phase: CGFloat = 0

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            content
                .mask(GradientMask(phase: phase).scaleEffect(3))
        }
    }

    /// A slanted, animatable gradient between transparent and opaque to use as mask.
    /// The `phase` parameter shifts the gradient, moving the opaque band.
    struct GradientMask: View {
        let phase: CGFloat
        let centerColor = Color.black
        let edgeColor = Color.black.opacity(0.3)

        var body: some View {
            LinearGradient(
                gradient:
                Gradient(stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension View {
    /// Adds an animated shimmering effect to any view, typically to show that
    /// an operation is in progress.
    /// - Parameters:
    ///   - duration: The duration of a shimmer cycle in seconds. Default: `1.5`.
    func shimmering(
        duration: Double = 1.5
    ) -> some View {
        modifier(Shimmer(duration: duration))
    }
}
