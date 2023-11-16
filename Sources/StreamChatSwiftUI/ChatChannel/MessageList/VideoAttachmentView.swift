//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import SwiftUI

public struct VideoAttachmentsContainer<Factory: ViewFactory>: View {

    @Injected(\.utils) private var utils

    var factory: Factory
    let message: ChatMessage
    let width: CGFloat
    @Binding var scrolledId: String?

    public var body: some View {
        VStack(spacing: 0) {
            if let quotedMessage = utils.messageCachingUtils.quotedMessage(for: message) {
                VStack {
                    factory.makeQuotedMessageView(
                        quotedMessage: quotedMessage,
                        fillAvailableSpace: !message.attachmentCounts.isEmpty,
                        isInComposer: false,
                        scrolledId: $scrolledId
                    )

                    VideoAttachmentsList(
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
                    message: message,
                    width: width
                )
            }

            if !message.text.isEmpty {
                AttachmentTextView(message: message)
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

public struct VideoAttachmentsList: View {

    let message: ChatMessage
    let width: CGFloat

    public init(message: ChatMessage, width: CGFloat) {
        self.message = message
        self.width = width
    }

    public var body: some View {
        VStack {
            ForEach(message.videoAttachments, id: \.self) { attachment in
                VideoAttachmentView(
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

public struct VideoAttachmentView: View {

    let attachment: ChatMessageVideoAttachment
    let message: ChatMessage
    let width: CGFloat
    var ratio: CGFloat = 0.75
    var cornerRadius: CGFloat = 24

    public init(
        attachment: ChatMessageVideoAttachment,
        message: ChatMessage,
        width: CGFloat,
        ratio: CGFloat = 0.75,
        cornerRadius: CGFloat = 24
    ) {
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
            attachment: attachment,
            author: message.author,
            width: width,
            ratio: ratio,
            cornerRadius: cornerRadius
        )
        .accessibilityIdentifier("VideoAttachmentView")
    }
}

struct VideoAttachmentContentView: View {

    @Injected(\.utils) private var utils
    @Injected(\.images) private var images

    private var videoPreviewLoader: VideoPreviewLoader {
        utils.videoPreviewLoader
    }

    let attachment: ChatMessageVideoAttachment
    let author: ChatUser
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

                if width > 64 && attachment.uploadingState == nil {
                    VStack {
                        Image(uiImage: images.playFilled)
                            .customizable()
                            .frame(width: 24)
                            .foregroundColor(.white)
                            .modifier(ShadowModifier())
                    }
                    .frame(width: width, height: width * ratio)
                    .contentShape(Rectangle())
                    .clipped()
                    .onTapGesture {
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
            VideoPlayerView(
                attachment: attachment,
                author: author,
                isShown: $fullScreenShown
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
