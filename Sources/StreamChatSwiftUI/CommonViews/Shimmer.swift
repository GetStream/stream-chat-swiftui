//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration = 1.5
    var delay = 0.25

    public func body(content: Content) -> some View {
        content
            .modifier(AnimatedMask(phase: phase))
            .animation(
                .linear(
                    duration: duration
                )
                .delay(delay)
                .repeatForever(
                    autoreverses: false
                ),
                value: phase == 0.0
            )
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
    ///   - delay: The delay until the animation re-starts.
    func shimmering(
        duration: Double = 1.5,
        delay: Double = 0.25
    ) -> some View {
        modifier(Shimmer(duration: duration, delay: delay))
    }
}
