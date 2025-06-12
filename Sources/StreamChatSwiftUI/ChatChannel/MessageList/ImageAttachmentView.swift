//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ImageAttachmentContainer<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors

    var factory: Factory
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    @Binding var scrolledId: String?

    @State private var galleryShown = false
    @State private var selectedIndex = 0

    public var body: some View {
        VStack(
            alignment: message.alignmentInBubble,
            spacing: 0
        ) {
            if let quotedMessage = message.quotedMessage {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
            }

            VStack(
                alignment: message.alignmentInBubble,
                spacing: 0
            ) {
                ImageAttachmentView(
                    message: message,
                    sources: sources,
                    width: width
                ) { index in
                    if message.localState == nil {
                        selectedIndex = index
                        galleryShown = true
                    }
                }

                if !message.text.isEmpty {
                    AttachmentTextView(message: message)
                        .frame(width: width)
                }
            }
        }
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message, isFirst: isFirst && message.videoAttachments.isEmpty
                )
            )
        )
        .fullScreenCover(isPresented: $galleryShown, onDismiss: {
            self.selectedIndex = 0
        }) {
            factory.makeGalleryView(
                mediaAttachments: sources,
                message: message,
                isShown: $galleryShown,
                options: .init(selectedIndex: selectedIndex)
            )
        }
        .accessibilityIdentifier("ImageAttachmentContainer")
    }
    
    private var sources: [MediaAttachment] {
        let videoSources = message.videoAttachments.map { attachment in
            let url: URL
            if let state = attachment.uploadingState {
                url = state.localFileURL
            } else {
                url = attachment.videoURL
            }
            return MediaAttachment(
                url: url,
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
                uploadingState: attachment.uploadingState
            )
        }
        return videoSources + imageSources
    }
}

public struct AttachmentTextView: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var message: ChatMessage
    let injectedBackgroundColor: UIColor?

    public init(message: ChatMessage, injectedBackgroundColor: UIColor? = nil) {
        self.message = message
        self.injectedBackgroundColor = injectedBackgroundColor
    }

    public var body: some View {
        HStack {
            StreamTextView(message: message)
                .standardPadding()
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .background(Color(backgroundColor))
        .accessibilityIdentifier("AttachmentTextView")
    }

    private var backgroundColor: UIColor {
        if let injectedBackgroundColor {
            return injectedBackgroundColor
        }
        var colors = colors
        if message.isSentByCurrentUser {
            if message.type == .ephemeral {
                return colors.background8
            } else {
                return colors.messageCurrentUserBackground[0]
            }
        } else {
            return colors.messageOtherUserBackground[0]
        }
    }
}

struct ImageAttachmentView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils

    let message: ChatMessage
    let sources: [MediaAttachment]
    let width: CGFloat
    var imageTapped: ((Int) -> Void)? = nil

    private let spacing: CGFloat = 2
    private let maxDisplayedImages = 4

    private var imageCDN: ImageCDN {
        utils.imageCDN
    }

    var body: some View {
        Group {
            if sources.count == 1 {
                SingleImageView(
                    source: sources[0],
                    width: width,
                    imageTapped: imageTapped,
                    index: 0
                )
                .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0].url)
            } else if sources.count == 2 {
                HStack(spacing: spacing) {
                    MultiImageView(
                        source: sources[0],
                        width: width / 2,
                        height: fullHeight,
                        imageTapped: imageTapped,
                        index: 0
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0].url)

                    MultiImageView(
                        source: sources[1],
                        width: width / 2,
                        height: fullHeight,
                        imageTapped: imageTapped,
                        index: 1
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1].url)
                }
            } else if sources.count == 3 {
                HStack(spacing: spacing) {
                    MultiImageView(
                        source: sources[0],
                        width: width / 2,
                        height: fullHeight,
                        imageTapped: imageTapped,
                        index: 0
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0].url)

                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[1],
                            width: width / 2,
                            height: fullHeight / 2,
                            imageTapped: imageTapped,
                            index: 1
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1].url)

                        MultiImageView(
                            source: sources[2],
                            width: width / 2,
                            height: fullHeight / 2,
                            imageTapped: imageTapped,
                            index: 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 2), url: sources[2].url)
                    }
                }
            } else if sources.count > 3 {
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[0],
                            width: width / 2,
                            height: fullHeight / 2,
                            imageTapped: imageTapped,
                            index: 0
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0].url)

                        MultiImageView(
                            source: sources[2],
                            width: width / 2,
                            height: fullHeight / 2,
                            imageTapped: imageTapped,
                            index: 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 2), url: sources[2].url)
                    }

                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[1],
                            width: width / 2,
                            height: fullHeight / 2,
                            imageTapped: imageTapped,
                            index: 1
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1].url)

                        ZStack {
                            MultiImageView(
                                source: sources[3],
                                width: width / 2,
                                height: fullHeight / 2,
                                imageTapped: imageTapped,
                                index: 3
                            )
                            .withUploadingStateIndicator(for: uploadState(for: 3), url: sources[3].url)

                            if notDisplayedImages > 0 {
                                Color.black.opacity(0.4)
                                    .allowsHitTesting(false)

                                Text("+\(notDisplayedImages)")
                                    .foregroundColor(Color(colors.staticColorText))
                                    .font(fonts.title)
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(width: width / 2, height: fullHeight / 2)
                    }
                }
            }
        }
        .frame(width: width, height: fullHeight)
    }

    private var fullHeight: CGFloat {
        3 * width / 4
    }

    private var notDisplayedImages: Int {
        sources.count > maxDisplayedImages ? sources.count - maxDisplayedImages : 0
    }

    private func uploadState(for index: Int) -> AttachmentUploadingState? {
        sources[index].uploadingState
    }
}

struct SingleImageView: View {
    let source: MediaAttachment
    let width: CGFloat
    var imageTapped: ((Int) -> Void)? = nil
    var index: Int?

    private var height: CGFloat {
        3 * width / 4
    }

    var body: some View {
        LazyLoadingImage(
            source: source,
            width: width,
            height: height,
            imageTapped: imageTapped,
            index: index
        )
        .frame(width: width, height: height)
        .accessibilityIdentifier("SingleImageView")
    }
}

struct MultiImageView: View {
    let source: MediaAttachment
    let width: CGFloat
    let height: CGFloat
    var imageTapped: ((Int) -> Void)? = nil
    var index: Int?

    var body: some View {
        LazyLoadingImage(
            source: source,
            width: width,
            height: height,
            imageTapped: imageTapped,
            index: index
        )
        .frame(width: width, height: height)
        .accessibilityIdentifier("MultiImageView")
    }
}

struct LazyLoadingImage: View {
    @Injected(\.utils) private var utils

    @State private var image: UIImage?
    @State private var error: Error?

    let source: MediaAttachment
    let width: CGFloat
    let height: CGFloat
    var resize: Bool = true
    var shouldSetFrame: Bool = true
    var imageTapped: ((Int) -> Void)? = nil
    var index: Int?
    var onImageLoaded: (UIImage) -> Void = { _ in /* Default implementation. */ }

    var body: some View {
        ZStack {
            if let image = image {
                imageView(for: image)
                if let imageTapped = imageTapped {
                    // NOTE: needed because of bug with SwiftUI.
                    // The click area expands outside the image view (although not visible).
                    Rectangle()
                        .opacity(0.000001)
                        .frame(width: width, height: height)
                        .clipped()
                        .allowsHitTesting(true)
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded { _ in
                                    imageTapped(index ?? 0)
                                }
                        )
                        .accessibilityLabel(L10n.Message.Attachment.accessibilityLabel((index ?? 0) + 1))
                        .accessibilityAddTraits(source.type == .video ? .startsMediaSession : .isImage)
                        .accessibilityAction {
                            imageTapped(index ?? 0)
                        }
                }
            } else if error != nil {
                Color(.secondarySystemBackground)
            } else {
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            }
            
            if source.type == .video && width > 64 && source.uploadingState == nil {
                VideoPlayIcon()
                    .accessibilityHidden(true)
            }
        }
        .onAppear {
            if image != nil {
                return
            }

            source.generateThumbnail(
                resize: resize,
                preferredSize: CGSize(width: width, height: height)
            ) { result in
                StreamConcurrency.onMain {
                    switch result {
                    case let .success(image):
                        self.image = image
                        onImageLoaded(image)
                    case let .failure(error):
                        self.error = error
                    }
                }
            }
        }
    }

    func imageView(for image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .aspectRatio(contentMode: .fill)
            .frame(width: shouldSetFrame ? width : nil, height: shouldSetFrame ? height : nil)
            .allowsHitTesting(false)
            .scaleEffect(1.0001) // Needed because of SwiftUI sometimes incorrectly displaying landscape images.
            .clipped()
            .accessibilityHidden(true)
    }
}

extension ChatMessage {

    var alignmentInBubble: HorizontalAlignment {
        .leading
    }
}

public struct MediaAttachment {
    @Injected(\.utils) var utils
    
    let url: URL
    let type: MediaAttachmentType
    var uploadingState: AttachmentUploadingState?
    
    func generateThumbnail(
        resize: Bool,
        preferredSize: CGSize,
        completion: @escaping @Sendable(Result<UIImage, Error>) -> Void
    ) {
        if type == .image {
            utils.imageLoader.loadImage(
                url: url,
                imageCDN: utils.imageCDN,
                resize: resize,
                preferredSize: preferredSize,
                completion: completion
            )
        } else if type == .video {
            utils.videoPreviewLoader.loadPreviewForVideo(
                at: url,
                completion: completion
            )
        }
    }
}

extension MediaAttachment {
    init(from attachment: ChatMessageImageAttachment) {
        let url: URL
        if let state = attachment.uploadingState {
            url = state.localFileURL
        } else {
            url = attachment.imageURL
        }
        self.init(
            url: url,
            type: .image,
            uploadingState: attachment.uploadingState
        )
    }
}

enum MediaAttachmentType {
    case image
    case video
}

/// Options for the gallery view.
public struct MediaViewsOptions {
    /// The index of the selected media item.
    public let selectedIndex: Int
}
