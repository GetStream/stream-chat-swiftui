//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct Shimmer: ViewModifier {
    /// The duration of a shimmer cycle in seconds. Default: `1.5`.
    var duration: Double = 1.5
    /// The delay until the animation re-starts.
    var delay: Double = 0.25

    @State private var isInitialState = true

    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: .init(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
                    startPoint: (isInitialState ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3))
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
