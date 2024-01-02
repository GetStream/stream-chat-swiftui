//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View shown when other users are typing.
public struct TypingIndicatorView: View {

    @State private var isTyping = false

    private let animationDuration: CGFloat = 0.75

    public init() { /* Public init */ }

    public var body: some View {
        HStack(spacing: 4) {
            TypingIndicatorCircle(isTyping: isTyping)
                .animation(
                    .easeOut(duration: animationDuration)
                        .repeatForever(autoreverses: true), value: isTyping
                )
            TypingIndicatorCircle(isTyping: isTyping)
                .animation(
                    .easeInOut(duration: animationDuration)
                        .repeatForever(autoreverses: true), value: isTyping
                )
            TypingIndicatorCircle(isTyping: isTyping)
                .animation(
                    .easeIn(duration: animationDuration)
                        .repeatForever(autoreverses: true), value: isTyping
                )
        }
        .onAppear {
            /// NOTE: This is needed because of a glitch when the animation is performed in a navigation bar.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTyping = true
            }
        }
    }
}

/// View that represents one circle of the typing indicator view.
private struct TypingIndicatorCircle: View {

    private let circleWidth: CGFloat = 4
    private let circleHeight: CGFloat = 4
    private let yOffset: CGFloat = 1.5
    private let minOpacity: CGFloat = 0.1
    private let maxOpacity: CGFloat = 1.0

    var isTyping: Bool

    var body: some View {
        Circle()
            .frame(width: circleWidth, height: circleHeight)
            .opacity(isTyping ? maxOpacity : minOpacity)
            .offset(y: isTyping ? yOffset : -yOffset)
    }
}
