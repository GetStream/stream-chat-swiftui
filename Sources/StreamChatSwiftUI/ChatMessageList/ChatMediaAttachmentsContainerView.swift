//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The orientation of media attachments in a gallery, determined by the
/// first attachment's original dimensions.
public enum MediaGalleryOrientation: Sendable {
    case landscape
    case portrait
    case square

    /// Initializes the orientation from the given pixel dimensions.
    ///
    /// Uses a tolerance of 20% around a 1:1 ratio to classify near-square
    /// images as ``square``. Falls back to ``landscape`` when dimensions
    /// are unavailable.
    public init(width: Double?, height: Double?) {
        guard let width, let height, width > 0, height > 0 else {
            self = .landscape
            return
        }
        let ratio = width / height
        if ratio > 1.2 {
            self = .landscape
        } else if ratio < 0.8 {
            self = .portrait
        } else {
            self = .square
        }
    }
}

/// A container view that displays media (image and video) attachments in a
/// gallery grid layout.
///
/// The layout adapts based on the orientation (landscape, portrait, square)
/// of the first image attachment and the total number of media items:
/// - **1 item**: Full-bleed single image whose container aspect ratio
///   matches the detected orientation.
/// - **2 items**: Two items side by side in a landscape-aspect container.
/// - **3 items**: One item on the left (full height) with two stacked
///   on the right.
/// - **4+ items**: A 2×2 grid. When there are more than four items the
///   last visible cell shows a "+N" overlay with the remaining count.
///
/// This view does **not** render message text or a bubble background.
/// Tapping any cell opens the full-screen gallery.
public struct ChatMediaAttachmentsContainerView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let message: ChatMessage
    let width: CGFloat

    @State private var galleryShown = false
    @State private var selectedIndex = 0
    @State private var isThumbnailLoading = true

    private var spacing: CGFloat { tokens.spacingXxxs }
    private var cornerRadius: CGFloat { tokens.messageBubbleRadiusAttachment }
    private let maxDisplayedItems = 4

    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat
    ) {
        self.factory = factory
        self.message = message
        self.width = width
    }

    public var body: some View {
        ZStack {
            galleryGrid
            if isThumbnailLoading {
                factory.makeLoadingView(options: .init(type: .spinner))
            }
        }
        .onPreferenceChange(ThumbnailLoadingKey.self) { isLoading in
            isThumbnailLoading = isLoading
        }
        .fullScreenCover(isPresented: $galleryShown, onDismiss: {
            selectedIndex = 0
        }) {
            factory.makeGalleryView(
                options: GalleryViewOptions(
                    mediaAttachments: sources,
                    message: message,
                    isShown: $galleryShown,
                    options: .init(selectedIndex: selectedIndex)
                )
            )
        }
        .accessibilityIdentifier("ChatMediaAttachmentsContainerView")
    }

    // MARK: - Layout

    @ViewBuilder
    private var galleryGrid: some View {
        let items = sources
        let size = containerSize(for: items.count)

        Group {
            switch items.count {
            case 0:
                EmptyView()
            case 1:
                singleItemLayout(items[0], width: size.width, height: size.height)
            case 2:
                twoItemLayout(items, height: size.height)
            case 3:
                threeItemLayout(items, height: size.height)
            default:
                fourPlusItemLayout(items, height: size.height)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func singleItemLayout(
        _ item: MediaAttachment,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        mediaCell(item, width: width, height: height, index: 0)
    }

    private func twoItemLayout(
        _ items: [MediaAttachment],
        height: CGFloat
    ) -> some View {
        let cellWidth = (width - spacing) / 2
        return HStack(spacing: spacing) {
            mediaCell(items[0], width: cellWidth, height: height, index: 0)
            mediaCell(items[1], width: cellWidth, height: height, index: 1)
        }
    }

    private func threeItemLayout(
        _ items: [MediaAttachment],
        height: CGFloat
    ) -> some View {
        let cellWidth = (width - spacing) / 2
        let cellHeight = (height - spacing) / 2
        return HStack(spacing: spacing) {
            mediaCell(items[0], width: cellWidth, height: height, index: 0)
            VStack(spacing: spacing) {
                mediaCell(items[1], width: cellWidth, height: cellHeight, index: 1)
                mediaCell(items[2], width: cellWidth, height: cellHeight, index: 2)
            }
        }
    }

    private func fourPlusItemLayout(
        _ items: [MediaAttachment],
        height: CGFloat
    ) -> some View {
        let cellWidth = (width - spacing) / 2
        let cellHeight = (height - spacing) / 2
        return HStack(spacing: spacing) {
            VStack(spacing: spacing) {
                mediaCell(items[0], width: cellWidth, height: cellHeight, index: 0)
                mediaCell(items[2], width: cellWidth, height: cellHeight, index: 2)
            }
            VStack(spacing: spacing) {
                mediaCell(items[1], width: cellWidth, height: cellHeight, index: 1)
                ZStack {
                    mediaCell(items[3], width: cellWidth, height: cellHeight, index: 3)
                    if remainingCount > 0 {
                        Color.black.opacity(0.4)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            .allowsHitTesting(false)
                        Text("+\(remainingCount)")
                            .foregroundColor(Color(colors.staticColorText))
                            .font(fonts.title)
                            .allowsHitTesting(false)
                    }
                }
                .frame(width: cellWidth, height: cellHeight)
            }
        }
    }

    // MARK: - Cell

    private func mediaCell(
        _ item: MediaAttachment,
        width: CGFloat,
        height: CGFloat,
        index: Int
    ) -> some View {
        ChatMediaAttachmentContentView(
            source: item,
            width: width,
            height: height,
            cornerRadius: cornerRadius,
            isOutgoing: message.isSentByCurrentUser
        )
        .withUploadingStateIndicator(for: item.uploadingState, url: item.url)
        .contentShape(Rectangle())
        .onTapGesture {
            if message.localState == nil {
                selectedIndex = index
                galleryShown = true
            }
        }
        .accessibilityLabel(L10n.Message.Attachment.accessibilityLabel(index + 1))
        .accessibilityAddTraits(item.type == .video ? .startsMediaSession : .isImage)
    }

    // MARK: - Data

    private var orientation: MediaGalleryOrientation {
        if let first = sources.first {
            return MediaGalleryOrientation(
                width: first.originalWidth,
                height: first.originalHeight
            )
        }
        return .landscape
    }

    private var sources: [MediaAttachment] {
        let videoSources = message.videoAttachments.map { attachment in
            MediaAttachment(
                url: attachment.videoURL,
                type: .video,
                uploadingState: attachment.uploadingState
            )
        }
        let imageSources = message.imageAttachments.map { attachment in
            let url: URL
            if let state = attachment.uploadingState {
                url = state.localFileURL
            } else {
                url = attachment.imageURL
            }
            return MediaAttachment(
                url: url,
                type: .image,
                uploadingState: attachment.uploadingState,
                originalWidth: attachment.originalWidth,
                originalHeight: attachment.originalHeight
            )
        }
        return videoSources + imageSources
    }

    private func containerSize(for itemCount: Int) -> CGSize {
        guard itemCount > 0 else { return .zero }
        if itemCount == 1 {
            switch orientation {
            case .landscape:
                // Width-constrained: 256×192 at max width
                return CGSize(width: width, height: width * 3.0 / 4.0)
            case .portrait:
                // Height-constrained: 192×256 at max width
                return CGSize(width: width * 3.0 / 4.0, height: width)
            case .square:
                return CGSize(width: width, height: width)
            }
        } else {
            // Multi-item always uses landscape ratio
            return CGSize(width: width, height: width * 3.0 / 4.0)
        }
    }

    private var remainingCount: Int {
        max(sources.count - maxDisplayedItems, 0)
    }
}
