//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import SwiftUI

public struct VideoAttachmentsContainer: View {
    let message: ChatMessage
    let width: CGFloat
    @Binding var scrolledId: String?
    
    public var body: some View {
        VStack {
            if let quotedMessage = message.quotedMessage {
                VStack {
                    QuotedMessageViewContainer(
                        quotedMessage: quotedMessage,
                        fillAvailableSpace: !message.attachmentCounts.isEmpty,
                        scrolledId: $scrolledId
                    )
                    
                    VideoAttachmentsList(
                        message: message,
                        width: width
                    )
                }
                .messageBubble(for: message, isFirst: false)
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
    
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    
    private var videoPreviewLoader: VideoPreviewLoader {
        utils.videoPreviewLoader
    }
    
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
                
                Button {
                    fullScreenShown = true
                } label: {
                    Image(uiImage: images.playFilled)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                        .foregroundColor(.white)
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
                author: message.author,
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
