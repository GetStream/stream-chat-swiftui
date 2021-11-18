//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import SwiftUI

public struct VideoAttachmentsContainer: View {
    let message: ChatMessage
    let width: CGFloat
        
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
    @Injected(\.utils) var utils
    
    private var videoPreviewLoader: VideoPreviewLoader {
        utils.videoPreviewLoader
    }
    
    let attachment: ChatMessageVideoAttachment
    let message: ChatMessage
    let width: CGFloat
    
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
                
                Button {
                    fullScreenShown = true
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding(.all, 32)
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
        .frame(width: width, height: 3 * width / 4)
        .cornerRadius(24)
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
        .cornerRadius(24)
    }
}
