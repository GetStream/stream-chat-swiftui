//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import SwiftUI

public struct VideoAttachmentsContainer<Factory: ViewFactory>: View {
    var factory: Factory
    let message: ChatMessage
    let width: CGFloat
    @Binding var scrolledId: String?

    public var body: some View {
        VStack(spacing: 0) {
            if let quotedMessage = message.quotedMessage {
                VStack {
                    factory.makeQuotedMessageView(
                        quotedMessage: quotedMessage,
                        fillAvailableSpace: !message.attachmentCounts.isEmpty,
                        isInComposer: false,
                        scrolledId: $scrolledId
                    )

                    VideoAttachmentsList(
                        factory: factory,
                        message: message,
                        width: width
                    )
                }
                .modifier(
                    factory.makeMessageViewModifier(
                        for: MessageModifierInfo(
                            message: message,
                            isFirst: false
                        )
                    )
                )
            } else {
                VideoAttachmentsList(
                    factory: factory,
                    message: message,
                    width: width
                )
            }

            if !message.text.isEmpty {
                AttachmentTextView(factory: factory, message: message)
                    .frame(width: width)
            }
        }
        .if(!message.text.isEmpty, transform: { view in
            view.modifier(
                factory.makeMessageViewModifier(
                    for: MessageModifierInfo(
                        message: message,
                        isFirst: true,
                        cornerRadius: 24
                    )
                )
            )
        })
        .accessibilityIdentifier("VideoAttachmentsContainer")
    }
}

public struct VideoAttachmentsList<Factory: ViewFactory>: View {
    let factory: Factory
    let message: ChatMessage
    let width: CGFloat

    public init(
        factory: Factory = DefaultViewFactory.shared,
        message: ChatMessage,
        width: CGFloat
    ) {
        self.factory = factory
        self.message = message
        self.width = width
    }

    public var body: some View {
        VStack {
            ForEach(message.videoAttachments, id: \.self) { attachment in
                VideoAttachmentView(
                    factory: factory,
                    attachment: attachment,
                    message: message,
                    width: width
                )
                .withUploadingStateIndicator(
                    for: attachment.uploadingState,
                    url: attachment.videoURL
                )
            }
        }
    }
}

public struct VideoAttachmentView<Factory: ViewFactory>: View {
    let factory: Factory
    let attachment: ChatMessageVideoAttachment
    let message: ChatMessage
    let width: CGFloat
    var ratio: CGFloat = 0.75
    var cornerRadius: CGFloat = 24

    public init(
        factory: Factory = DefaultViewFactory.shared,
        attachment: ChatMessageVideoAttachment,
        message: ChatMessage,
        width: CGFloat,
        ratio: CGFloat = 0.75,
        cornerRadius: CGFloat = 24
    ) {
        self.factory = factory
        self.attachment = attachment
        self.message = message
        self.width = width
        self.ratio = ratio
        self.cornerRadius = cornerRadius
    }

    @State var previewImage: UIImage?
    @State var error: Error?
    @State var fullScreenShown = false

    public var body: some View {
        VideoAttachmentContentView(
            factory: factory,
            attachment: attachment,
            message: message,
            width: width,
            ratio: ratio,
            cornerRadius: cornerRadius
        )
        .accessibilityIdentifier("VideoAttachmentView")
    }
}

struct VideoAttachmentContentView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images

    private var videoPreviewLoader: VideoPreviewLoader {
        utils.videoPreviewLoader
    }

    let factory: Factory
    let attachment: ChatMessageVideoAttachment
    let message: ChatMessage
    let width: CGFloat
    var ratio: CGFloat = 0.75
    var cornerRadius: CGFloat = 24

    @State var previewImage: UIImage?
    @State var error: Error?
    @State var fullScreenShown = false

    public var body: some View {
        ZStack {
            if let previewImage = previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                if width > 64 && attachment.uploadingState == nil {
                    VStack {
                        VideoPlayIcon()
                    }
                    .frame(width: width, height: width * ratio)
                    .contentShape(Rectangle())
                    .clipped()
                    .onTapGesture {
                        fullScreenShown = true
                    }
                    .accessibilityAction {
                        fullScreenShown = true
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
        }
        .frame(width: width, height: width * ratio)
        .cornerRadius(cornerRadius)
        .fullScreenCover(isPresented: $fullScreenShown) {
            factory.makeVideoPlayerView(
                attachment: attachment,
                message: message,
                isShown: $fullScreenShown,
                options: .init(selectedIndex: 0)
            )
        }
        .onAppear {
            videoPreviewLoader.loadPreviewForVideo(at: attachment.videoURL) { result in
                switch result {
                case let .success(image):
                    self.previewImage = image
                case let .failure(error):
                    self.error = error
                }
            }
        }
    }
}

struct VideoPlayIcon: View {
    @Injected(\.images) var images
    
    var width: CGFloat = 24
    
    var body: some View {
        Image(uiImage: images.playFilled)
            .customizable()
            .frame(width: width)
            .foregroundColor(.white)
            .modifier(ShadowModifier())
    }
}
