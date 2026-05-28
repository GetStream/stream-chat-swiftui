//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A view that renders a single media attachment (image or video) thumbnail.
///
/// Images are loaded through ``StreamAsyncImage``, which consults Nuke's
/// in-memory cache synchronously and avoids a loading flash when the
/// thumbnail was rendered earlier (e.g. when the message is shown again
/// inside the reactions overlay). Video thumbnails go through
/// ``MediaAttachment/generateThumbnail(resize:preferredSize:completion:)``
/// because they can originate from ``AVAssetImageGenerator`` and are not
/// pure image URLs.
///
/// Shows a gradient placeholder and a spinner while the thumbnail is
/// loading. For video attachments, a play icon is overlaid on the
/// successfully loaded thumbnail.
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
    /// Which corners should be rounded. When `nil`, all corners are rounded
    /// using a continuous `RoundedRectangle`.
    let corners: UIRectCorner?
    /// Whether the message is sent by the current user (outgoing).
    let isOutgoing: Bool
    /// Called when the user taps the retry badge on an upload-failed attachment.
    let onUploadRetry: (() -> Void)?

    /// Video preview image, loaded once on appear.
    @State private var videoPreview: UIImage?
    /// Error from the most recent video preview load.
    @State private var videoPreviewError: Error?
    /// Bumped to force ``StreamAsyncImage`` to retry a failed image load.
    @State private var imageRetryToken = 0

    public init(
        factory: Factory,
        source: MediaAttachment,
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat? = nil,
        corners: UIRectCorner? = nil,
        isOutgoing: Bool = false,
        onUploadRetry: (() -> Void)? = nil
    ) {
        @Injected(\.tokens) var tokens
        self.factory = factory
        self.source = source
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius ?? tokens.messageBubbleRadiusAttachment
        self.corners = corners
        self.isOutgoing = isOutgoing
        self.onUploadRetry = onUploadRetry
    }

    private var isUploading: Bool {
        if case .uploading = source.uploadingState?.state {
            return true
        }
        return false
    }

    public var body: some View {
        ZStack {
            thumbnail
        }
        .frame(width: width, height: height)
        .if(cornerRadius > 0, transform: { content in
            content
                .clipShape(
                    BubbleBackgroundShape(
                        cornerRadius: cornerRadius,
                        corners: corners ?? [.topLeft, .topRight, .bottomLeft, .bottomRight]
                    )
                )
        })
        .accessibilityIdentifier("MessageMediaAttachmentContentView")
    }

    // MARK: - Thumbnail

    @ViewBuilder
    private var thumbnail: some View {
        if source.type == .image {
            imageThumbnail
        } else if source.type == .video {
            videoThumbnail
        } else {
            placeholderBackground
        }
    }

    @ViewBuilder
    private var imageThumbnail: some View {
        StreamAsyncImage(
            url: source.url,
            resize: ImageResize(CGSize(width: width, height: height))
        ) { phase in
            ZStack {
                phaseBackground(for: phase)
                imageOverlays(for: phase)
            }
        }
        .id(imageRetryToken)
    }

    @ViewBuilder
    private var videoThumbnail: some View {
        ZStack {
            videoBackground
            videoOverlays
        }
        .onAppear {
            guard videoPreview == nil else { return }
            loadVideoThumbnail()
        }
    }

    // MARK: - Phase Rendering (Image)

    @ViewBuilder
    private func phaseBackground(for phase: StreamAsyncImagePhase) -> some View {
        switch phase {
        case let .success(result):
            Image(uiImage: result.image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
        case .empty, .error:
            placeholderBackground
        case .loading:
            placeholderGradient
        }
    }

    @ViewBuilder
    private func imageOverlays(for phase: StreamAsyncImagePhase) -> some View {
        if case .loading = phase, !isUploading {
            LoadingSpinnerView(size: LoadingSpinnerSize.medium)
                .allowsHitTesting(false)
        }

        if case .error = phase, source.uploadingState == nil {
            retryOverlay { imageRetryToken &+= 1 }
        }

        if let uploadingState = source.uploadingState {
            uploadingOverlay(for: uploadingState)
        }
    }

    // MARK: - Video Rendering

    @ViewBuilder
    private var videoBackground: some View {
        if let videoPreview {
            Image(uiImage: videoPreview)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
        } else if videoPreviewError != nil {
            placeholderBackground
        } else {
            placeholderGradient
        }
    }

    @ViewBuilder
    private var videoOverlays: some View {
        if videoPreview == nil, videoPreviewError == nil, !isUploading {
            LoadingSpinnerView(size: LoadingSpinnerSize.medium)
                .allowsHitTesting(false)
        }

        if videoPreviewError != nil, source.uploadingState == nil {
            retryOverlay { loadVideoThumbnail() }
        }

        if let uploadingState = source.uploadingState {
            uploadingOverlay(for: uploadingState)
        }

        if width > 64, source.uploadingState == nil, videoPreview != nil, videoPreviewError == nil {
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.medium)
                .allowsHitTesting(false)
        }
    }

    // MARK: - Video Loading

    private func loadVideoThumbnail() {
        videoPreviewError = nil
        source.generateThumbnail(
            resize: true,
            preferredSize: CGSize(width: width, height: height)
        ) { result in
            switch result {
            case let .success(loaded):
                self.videoPreview = loaded
            case let .failure(failure):
                self.videoPreviewError = failure
            }
        }
    }

    // MARK: - Shared Overlays

    @ViewBuilder
    private func uploadingOverlay(for uploadingState: AttachmentUploadingState) -> some View {
        switch uploadingState.state {
        case let .uploading(progress):
            Color(colors.backgroundCoreOverlayLight)
                .allowsHitTesting(false)
            LoadingSpinnerView(
                size: LoadingSpinnerSize.medium,
                progress: Double(progress)
            )
            .allowsHitTesting(false)
        case .uploadingFailed:
            retryOverlay { onUploadRetry?() }
        default:
            EmptyView()
        }
    }

    private func retryOverlay(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Color(colors.backgroundCoreOverlayLight)
                RetryBadgeView()
            }
        }
        .buttonStyle(.plain)
    }

    private var placeholderBackground: some View {
        Color(isOutgoing ? colors.chatBackgroundAttachmentOutgoing : colors.chatBackgroundAttachmentIncoming)
    }

    private var placeholderGradient: some View {
        placeholderBackground.shimmering()
    }
}
