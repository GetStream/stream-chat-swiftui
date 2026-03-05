//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

enum ShimmerDirection {
    /// Sweeps from the leading (left) side towards trailing (right).
    case leadingToTrailing
    /// Sweeps from the trailing (right) side towards leading (left).
    case trailingToLeading
}

enum ShimmerIntensity {
    /// Standard shimmer with prominent highlight.
    case standard
    /// Softer shimmer with reduced highlight opacity.
    case subtle
}

struct Shimmer: ViewModifier {
    var duration: Double = 1.5
    var delay: Double = 0.25
    var direction: ShimmerDirection = .leadingToTrailing
    var intensity: ShimmerIntensity = .standard

    @State private var isInitialState = true

    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: .init(colors: gradientColors),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
            .animation(
                .linear(duration: duration)
                    .delay(delay)
                    .repeatForever(autoreverses: false),
                value: isInitialState
            )
            .onAppear {
                isInitialState = false
            }
    }

    private var gradientColors: [Color] {
        let dimOpacity: Double = intensity == .subtle ? 0.6 : 0.4
        return [.black.opacity(dimOpacity), .black, .black.opacity(dimOpacity)]
    }

    private var startPoint: UnitPoint {
        switch direction {
        case .leadingToTrailing:
            return isInitialState ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1)
        case .trailingToLeading:
            return isInitialState ? .init(x: 1.3, y: -0.3) : .init(x: 0, y: 1)
        }
    }

    private var endPoint: UnitPoint {
        switch direction {
        case .leadingToTrailing:
            return isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3)
        case .trailingToLeading:
            return isInitialState ? .init(x: 1, y: 0) : .init(x: -0.3, y: 1.3)
        }
    }
}

extension View {
    /// Adds an animated shimmering effect to any view, typically to show that
    /// an operation is in progress.
    /// - Parameters:
    ///   - duration: The duration of a shimmer cycle in seconds. Default: `1.5`.
    ///   - delay: The delay until the animation re-starts.
    ///   - direction: The sweep direction. Default: `.leadingToTrailing`.
    ///   - intensity: The visual intensity. Default: `.standard`.
    func shimmering(
        duration: Double = 1.5,
        delay: Double = 0.25,
        direction: ShimmerDirection = .leadingToTrailing,
        intensity: ShimmerIntensity = .standard
    ) -> some View {
        modifier(Shimmer(
            duration: duration,
            delay: delay,
            direction: direction,
            intensity: intensity
        ))
    }
}
