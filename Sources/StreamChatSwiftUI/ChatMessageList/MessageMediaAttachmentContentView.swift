//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A view that renders a single media attachment (image or video) thumbnail.
///
/// Uses ``MediaAttachment/generateThumbnail(resize:preferredSize:completion:)``
/// to load and display thumbnails.
/// Shows a gradient placeholder while the thumbnail is loading.
/// For video attachments, a play icon is overlaid on the thumbnail.
public struct MessageMediaAttachmentContentView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors

    /// The view factory used to create subviews.
    let factory: Factory
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
        factory: Factory,
        source: MediaAttachment,
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat? = nil,
        isOutgoing: Bool = false
    ) {
        @Injected(\.tokens) var tokens
        self.factory = factory
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

            if image == nil && error == nil {
                factory.makeLoadingView(options: .init(type: .spinner))
                    .allowsHitTesting(false)
            }

            if source.type == .video && width > 64 && source.uploadingState == nil {
                VideoPlayIndicatorView(size: VideoPlayIndicatorSize.medium)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onAppear {
            guard image == nil else { return }
            source.generateThumbnail(resize: true, preferredSize: CGSize(width: width, height: height)) { result in
                switch result {
                case .success(let image):
                    self.image = image
                case .failure(let failure):
                    self.error = failure
                }
            }
        }
        .accessibilityIdentifier("MessageMediaAttachmentContentView")
    }

    private var placeholderGradient: some View {
        Color(isOutgoing ? colors.chatBackgroundAttachmentOutgoing : colors.chatBackgroundAttachmentIncoming)
            .shimmering()
    }
}
