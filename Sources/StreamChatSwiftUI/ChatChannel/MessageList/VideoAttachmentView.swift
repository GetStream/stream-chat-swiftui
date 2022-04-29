//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
        VStack {
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
        }
    }
}

public struct VideoAttachmentsList: View {
    
    let message: ChatMessage
    let width: CGFloat
    
    public var body: some View {
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

public struct VideoAttachmentView: View {
    
    let attachment: ChatMessageVideoAttachment
    let message: ChatMessage
    let width: CGFloat
    var ratio: CGFloat = 0.75
    var cornerRadius: CGFloat = 24
    
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
                
                if width > 64 {
                    VStack {
                        Image(uiImage: images.playFilled)
                            .customizable()
                            .frame(width: 24)
                            .foregroundColor(.white)
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
