//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A preference key that tracks whether any media thumbnail is still loading.
///
/// Each ``ChatMediaAttachmentContentView`` reports `true` while its thumbnail
/// has not yet loaded. The values are reduced with `||` so the container
/// sees `true` as long as *any* child is still loading.
struct ThumbnailLoadingKey: PreferenceKey {
    static let defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

/// A view that renders a single media attachment (image or video) thumbnail.
///
/// Uses ``MediaAttachment/generateThumbnail(resize:preferredSize:completion:)``
/// to load and display thumbnails.
/// Shows a gradient placeholder while the thumbnail is loading.
/// For video attachments, a play icon is overlaid on the thumbnail.
public struct ChatMediaAttachmentContentView: View {
    @Injected(\.colors) private var colors

    /// The media attachment source to display.
    let source: MediaAttachment
    /// The width of the view.
    let width: CGFloat
    /// The height of the view.
    let height: CGFloat
    /// The corner radius applied to the view.
    let cornerRadius: CGFloat
    /// Whether the message is sent by the current user (outgoing).
    let isOutgoing: Bool

    @State private var image: UIImage?
    @State private var error: Error?

    public init(
        source: MediaAttachment,
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat? = nil,
        isOutgoing: Bool = false
    ) {
        @Injected(\.tokens) var tokens
        self.source = source
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius ?? tokens.messageBubbleRadiusAttachment
        self.isOutgoing = isOutgoing
    }

    public var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
            } else if error != nil {
                Color(.secondarySystemBackground)
            } else {
                placeholderGradient
            }

            if source.type == .video && width > 64 && source.uploadingState == nil {
                VideoPlayIcon()
                    .allowsHitTesting(false)
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .compatibility.task(id: source.url.absoluteString) { @MainActor in
            do {
                self.image = try await source.generateThumbnail(
                    resize: true,
                    preferredSize: CGSize(width: width, height: height)
                )
            } catch {
                self.error = error
            }
        }
        .accessibilityIdentifier("ChatMediaAttachmentContentView")
        .preference(key: ThumbnailLoadingKey.self, value: image == nil && error == nil)
    }

    private var placeholderGradient: some View {
        Color(isOutgoing ? colors.chatBackgroundAttachmentOutgoing : colors.chatBackgroundAttachmentIncoming)
            .shimmering()
    }
}
