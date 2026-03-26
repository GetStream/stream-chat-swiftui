//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Predefined sizes for ``VideoPlayIndicatorView``.
public enum VideoPlayIndicatorSize {
    @MainActor public static var extraLarge: CGFloat = 64
    @MainActor public static var large: CGFloat = 48
    @MainActor public static var medium: CGFloat = 40
    @MainActor public static var small: CGFloat = 20
}

/// A circular play/pause indicator for video content.
///
/// Renders a filled circle with a play or pause icon centered inside.
/// The ``playing`` parameter controls which icon is shown.
public struct VideoPlayIndicatorView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Environment(\.layoutDirection) private var layoutDirection

    let size: CGFloat
    let playing: Bool

    public init(size: CGFloat, playing: Bool = false) {
        self.size = size
        self.playing = playing
    }

    public var body: some View {
        Circle()
            .fill(Color(colors.controlPlayButtonBackground))
            .frame(width: size, height: size)
            .overlay(
                Image(uiImage: playing ? images.pauseFill : images.playFill)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(Color(colors.controlPlayButtonIcon))
                    .offset(x: offsetX)
            )
            .accessibilityIdentifier("VideoPlayIndicatorView")
    }
    
    private var iconSize: CGFloat {
        size / 2
    }
    
    private var offsetX: CGFloat {
        guard !playing else { return 0 }
        let offset = size / 16
        return layoutDirection == .rightToLeft ? -offset : offset
    }
}

@available(iOS 26, *)
#Preview {
    @Previewable let streamChat = StreamChat(chatClient: .init(config: .init(apiKeyString: "Preview")))
    
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.extraLarge)
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.large)
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.medium)
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.small)
        }
        HStack(spacing: 12) {
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.extraLarge, playing: true)
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.large, playing: true)
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.medium, playing: true)
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.small, playing: true)
        }
    }
    .padding()
}
