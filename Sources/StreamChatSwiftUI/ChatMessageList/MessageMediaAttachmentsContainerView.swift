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
    /// Uses a tolerance of 5% around a 1:1 ratio to classify near-square
    /// images as ``square``. Falls back to ``landscape`` when dimensions
    /// are unavailable.
    public init(width: Double?, height: Double?) {
        guard let width, let height, width > 0, height > 0 else {
            self = .landscape
            return
        }
        let ratio = width / height
        if ratio > 1.05 {
            self = .landscape
        } else if ratio < 0.95 {
            self = .portrait
        } else {
            self = .square
        }
    }
    
    init(mediaAttachments: [MediaAttachment]) {
        if let first = mediaAttachments.first {
            self = MediaGalleryOrientation(
                width: first.originalWidth,
                height: first.originalHeight
            )
        } else {
            self = .landscape
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
public struct MessageMediaAttachmentsContainerView<Factory: ViewFactory>: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool

    @State private var galleryShown = false
    @State private var selectedIndex = 0
    private var spacing: CGFloat { tokens.spacingXxxs }
    private var cornerRadius: CGFloat { tokens.messageBubbleRadiusAttachment }
    private let maxDisplayedItems = 4
    private let orientation: MediaGalleryOrientation
    private let sources: [MediaAttachment]

    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool = true
    ) {
        self.factory = factory
        self.message = message
        self.width = width
        self.isFirst = isFirst
        self.sources = MediaAttachment.galleryOrdered(from: message)
        self.orientation = MediaGalleryOrientation(mediaAttachments: sources)
    }

    public var body: some View {
        galleryGrid
            .onChange(of: selectedIndex) { _ in
                galleryShown = true
            }
            .fullScreenCover(isPresented: $galleryShown) {
                factory.makeMediaViewer(
                    options: MediaViewerOptions(
                        mediaAttachments: sources,
                        message: message,
                        isShown: $galleryShown,
                        options: .init(selectedIndex: selectedIndex)
                    )
                )
            }
            .accessibilityIdentifier("MessageMediaAttachmentsContainerView")
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
                twoItemLayout(items, size: size)
            case 3:
                threeItemLayout(items, size: size)
            default:
                fourPlusItemLayout(items, size: size)
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

    @ViewBuilder
    private func twoItemLayout(
        _ items: [MediaAttachment],
        size: CGSize
    ) -> some View {
        if orientation == .landscape {
            // Landscape: stacked vertically
            let cellHeight = (size.height - spacing) / 2
            VStack(spacing: spacing) {
                mediaCell(items[0], width: size.width, height: cellHeight, index: 0)
                mediaCell(items[1], width: size.width, height: cellHeight, index: 1)
            }
        } else {
            // Portrait / Square: side by side
            let cellWidth = (size.width - spacing) / 2
            HStack(spacing: spacing) {
                mediaCell(items[0], width: cellWidth, height: size.height, index: 0)
                mediaCell(items[1], width: cellWidth, height: size.height, index: 1)
            }
        }
    }

    @ViewBuilder
    private func threeItemLayout(
        _ items: [MediaAttachment],
        size: CGSize
    ) -> some View {
        if orientation == .landscape {
            // Landscape: top item full width, bottom two side by side
            let cellWidth = (size.width - spacing) / 2
            let cellHeight = (size.height - spacing) / 2
            VStack(spacing: spacing) {
                mediaCell(items[0], width: size.width, height: cellHeight, index: 0)
                HStack(spacing: spacing) {
                    mediaCell(items[1], width: cellWidth, height: cellHeight, index: 1)
                    mediaCell(items[2], width: cellWidth, height: cellHeight, index: 2)
                }
            }
        } else {
            // Portrait / Square: left item full height, right two stacked
            let cellWidth = (size.width - spacing) / 2
            let cellHeight = (size.height - spacing) / 2
            HStack(spacing: spacing) {
                mediaCell(items[0], width: cellWidth, height: size.height, index: 0)
                VStack(spacing: spacing) {
                    mediaCell(items[1], width: cellWidth, height: cellHeight, index: 1)
                    mediaCell(items[2], width: cellWidth, height: cellHeight, index: 2)
                }
            }
        }
    }

    @ViewBuilder
    private func fourPlusItemLayout(
        _ items: [MediaAttachment],
        size: CGSize
    ) -> some View {
        let cellWidth = (size.width - spacing) / 2
        let cellHeight = (size.height - spacing) / 2
        if orientation == .landscape {
            // Landscape: two rows (VStack of HStacks)
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    mediaCell(items[0], width: cellWidth, height: cellHeight, index: 0)
                    mediaCell(items[1], width: cellWidth, height: cellHeight, index: 1)
                }
                HStack(spacing: spacing) {
                    mediaCell(items[2], width: cellWidth, height: cellHeight, index: 2)
                    overflowCell(items[3], width: cellWidth, height: cellHeight, index: 3)
                }
            }
        } else {
            // Portrait / Square: two columns (HStack of VStacks)
            HStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    mediaCell(items[0], width: cellWidth, height: cellHeight, index: 0)
                    mediaCell(items[2], width: cellWidth, height: cellHeight, index: 2)
                }
                VStack(spacing: spacing) {
                    mediaCell(items[1], width: cellWidth, height: cellHeight, index: 1)
                    overflowCell(items[3], width: cellWidth, height: cellHeight, index: 3)
                }
            }
        }
    }

    private func overflowCell(
        _ item: MediaAttachment,
        width: CGFloat,
        height: CGFloat,
        index: Int
    ) -> some View {
        ZStack {
            mediaCell(item, width: width, height: height, index: index)
            if remainingCount > 0 {
                Color.black.opacity(0.4)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .allowsHitTesting(false)
                Text("+\(remainingCount)")
                    .foregroundColor(Color(colors.backgroundCoreElevation0))
                    .font(fonts.title)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: width, height: height)
    }

    // MARK: - Cell

    private func mediaCell(
        _ item: MediaAttachment,
        width: CGFloat,
        height: CGFloat,
        index: Int
    ) -> some View {
        return MessageMediaAttachmentContentView(
            factory: factory,
            source: item,
            width: width,
            height: height,
            cornerRadius: 0,
            corners: .allCorners,
            isOutgoing: message.isSentByCurrentUser,
            onUploadRetry: item.uploadingState?.state == .uploadingFailed ? { [message, chatClient] in
                guard let cid = message.cid else { return }
                let controller = chatClient.messageController(
                    cid: cid,
                    messageId: message.id
                )
                controller.resendMessage()
            } : nil
        )
        .modifier(
            factory.styles.makeMessageAttachmentItemViewModifier(
                options: MessageAttachmentItemViewModifierOptions(
                    message: message,
                    isFirst: isFirst,
                    attachmentType: item.type == .video ? .video : .image
                )
            )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if message.localState == nil {
                if selectedIndex == index {
                    galleryShown = true
                } else {
                    selectedIndex = index
                }
            }
        }
        .accessibilityLabel(L10n.Message.Attachment.accessibilityLabel(index + 1))
        .accessibilityAddTraits(item.type == .video ? .startsMediaSession : .isImage)
    }

    // MARK: - Data

    private func containerSize(for itemCount: Int) -> CGSize {
        Self.containerSize(for: itemCount, orientation: orientation, maxItemWidth: width)
    }
    
    static func containerSize(
        for itemCount: Int,
        orientation: MediaGalleryOrientation,
        maxItemWidth: CGFloat
    ) -> CGSize {
        guard itemCount > 0 else { return .zero }
        if itemCount == 1 {
            switch orientation {
            case .landscape:
                return CGSize(width: maxItemWidth, height: maxItemWidth * 3.0 / 4.0)
            case .portrait:
                return CGSize(width: maxItemWidth * 3.0 / 4.0, height: maxItemWidth)
            case .square:
                return CGSize(width: maxItemWidth, height: maxItemWidth)
            }
        } else {
            return CGSize(width: maxItemWidth, height: maxItemWidth * 3.0 / 4.0)
        }
    }

    private var remainingCount: Int {
        max(sources.count - maxDisplayedItems, 0)
    }
}
