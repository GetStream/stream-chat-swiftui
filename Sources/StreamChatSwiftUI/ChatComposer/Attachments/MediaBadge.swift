//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A media badge for video.
public struct VideoMediaBadge: View {
    @Injected(\.images) var images

    /// The duration in seconds.
    public let duration: Int

    public init(duration: Int) {
        self.duration = duration
    }

    public var body: some View {
        MediaBadge(
            icon: Image(uiImage: images.videoMediaIcon).renderingMode(.template),
            duration: duration
        )
    }
}

/// A media badge for audio.
public struct AudioMediaBadge: View {
    @Injected(\.images) var images

    /// The duration in seconds.
    public let duration: Int

    public init(duration: Int) {
        self.duration = duration
    }

    public var body: some View {
        MediaBadge(
            icon: Image(uiImage: images.audioMediaIcon).renderingMode(.template),
            duration: duration
        )
    }
}

/// A pill-shaped badge displaying an icon and duration.
public struct MediaBadge: View {
    @Injected(\.tokens) private var tokens
    @Injected(\.colors) private var colors

    /// The icon to display.
    public let icon: Image
    /// The duration in seconds.
    public let duration: Int

    public init(icon: Image, duration: Int) {
        self.icon = icon
        self.duration = duration
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            icon
                .frame(height: tokens.iconSizeXs)
            Text("\(duration)s")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(Color(colors.badgeTextInverse))
        .padding(.horizontal, tokens.spacingXs)
        .padding(.vertical, tokens.spacingXxs)
        .frame(minWidth: 45, minHeight: 20)
        .background(Color(colors.badgeBackgroundInverse))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(duration) seconds")
        .accessibilityAddTraits(.isStaticText)
    }
}

// TODO: Move to Common Module

extension Appearance.Images {
    var videoMediaIcon: UIImage {
        UIImage(
            systemName: "video.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 10)
        )!
    }

    var audioMediaIcon: UIImage {
        UIImage(
            systemName: "mic.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 10)
        )!
    }
}

// MARK: - Preview

#Preview {
    VStack {
        HStack(spacing: 16) {
            VideoMediaBadge(duration: 8)
            AudioMediaBadge(duration: 8)
        }
        HStack(spacing: 16) {
            VideoMediaBadge(duration: 18)
            AudioMediaBadge(duration: 18)
        }
    }
    .padding()
}
