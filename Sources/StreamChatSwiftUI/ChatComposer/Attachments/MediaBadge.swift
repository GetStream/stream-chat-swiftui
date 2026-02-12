//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A media badge for video.
public struct VideoMediaBadge: View {
    @Injected(\.images) var images

    /// The duration text to display (e.g. "8s").
    public let durationText: String

    public init(durationText: String) {
        self.durationText = durationText
    }

    public var body: some View {
        MediaBadge(
            icon: Image(uiImage: images.videoMediaIcon).renderingMode(.template),
            durationText: durationText
        )
    }
}

/// A media badge for audio.
public struct AudioMediaBadge: View {
    @Injected(\.images) var images

    /// The duration text to display (e.g. "8s").
    public let durationText: String

    public init(durationText: String) {
        self.durationText = durationText
    }

    public var body: some View {
        MediaBadge(
            icon: Image(uiImage: images.audioMediaIcon).renderingMode(.template),
            durationText: durationText
        )
    }
}

/// A pill-shaped badge displaying an icon and duration.
public struct MediaBadge: View {
    @Injected(\.tokens) private var tokens
    @Injected(\.colors) private var colors

    /// The icon to display.
    public let icon: Image
    /// The duration text to display (e.g. "8s").
    public let durationText: String

    public init(icon: Image, durationText: String) {
        self.icon = icon
        self.durationText = durationText
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            icon
                .frame(height: tokens.iconSizeXs)
            Text(durationText)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(Color(colors.badgeTextInverse))
        .padding(.horizontal, tokens.spacingXs)
        .padding(.vertical, tokens.spacingXxs)
        .frame(minWidth: 45, minHeight: 20)
        .background(Color(colors.badgeBackgroundInverse))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(durationText)
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - MediaBadgeOverlayModifier

/// Modifier that overlays a badge on the bottom-left corner of a view.
public struct MediaBadgeOverlayModifier<Badge: View>: ViewModifier {
    @Injected(\.tokens) private var tokens

    let badge: () -> Badge

    public init(@ViewBuilder badge: @escaping () -> Badge) {
        self.badge = badge
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        badge()
                        Spacer()
                    }
                }
                .padding(.leading, tokens.spacingXxs)
                .padding(.bottom, tokens.spacingXxs),
                alignment: .bottomLeading
            )
    }
}

extension View {
    /// Overlays a badge on the bottom-left corner of the view.
    public func mediaBadgeOverlay<Badge: View>(@ViewBuilder badge: @escaping () -> Badge) -> some View {
        modifier(MediaBadgeOverlayModifier(badge: badge))
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

#Preview("Badges") {
    VStack {
        HStack(spacing: 16) {
            VideoMediaBadge(durationText: "8s")
            AudioMediaBadge(durationText: "8s")
        }
        HStack(spacing: 16) {
            VideoMediaBadge(durationText: "18s")
            AudioMediaBadge(durationText: "18s")
        }
    }
    .padding()
}
