//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Nuke
import NukeUI
import StreamChat
import SwiftUI

public struct ImageAttachmentContainer: View {
    @Injected(\.colors) var colors
    
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
                
    public var body: some View {
        if message.text.isEmpty {
            ImageAttachmentView(
                message: message,
                width: width
            )
            .messageBubble(for: message, isFirst: isFirst)
        } else {
            VStack(spacing: 0) {
                ImageAttachmentView(
                    message: message,
                    width: width
                )
                
                HStack {
                    Text(message.text)
                        .standardPadding()
                    Spacer()
                }
                .background(Color(backgroundColor))
            }
            .messageBubble(for: message, isFirst: isFirst)
        }
    }
    
    private var backgroundColor: UIColor {
        if message.isSentByCurrentUser {
            if message.type == .ephemeral {
                return colors.background8
            } else {
                return colors.background6
            }
        } else {
            return colors.background8
        }
    }
}

struct ImageAttachmentView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.utils) var utils
    
    let message: ChatMessage
    let width: CGFloat
    
    private let spacing: CGFloat = 2
    private let maxDisplayedImages = 4
    
    private var imageCDN: ImageCDN {
        utils.imageCDN
    }
    
    private var sources: [URL] {
        message.imageAttachments.map { attachment in
            if let state = attachment.uploadingState {
                return state.localFileURL
            } else {
                return attachment.imagePreviewURL
            }
        }
    }
    
    var body: some View {
        Group {
            if sources.count == 1 {
                SingleImageView(
                    source: sources[0],
                    width: width
                )
                .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
            } else if sources.count == 2 {
                HStack(spacing: spacing) {
                    MultiImageView(
                        source: sources[0],
                        width: width / 2,
                        height: width
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
                    
                    MultiImageView(
                        source: sources[1],
                        width: width / 2,
                        height: width
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1])
                }
                .aspectRatio(1, contentMode: .fill)
            } else if sources.count == 3 {
                HStack(spacing: spacing) {
                    MultiImageView(
                        source: sources[0],
                        width: width / 2,
                        height: width
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
                    
                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[1],
                            width: width / 2,
                            height: width / 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1])
                        
                        MultiImageView(
                            source: sources[2],
                            width: width / 2,
                            height: width / 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 2), url: sources[2])
                    }
                }
                .aspectRatio(1, contentMode: .fill)
            } else if sources.count > 3 {
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[0],
                            width: width / 2,
                            height: width / 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
                        
                        MultiImageView(
                            source: sources[1],
                            width: width / 2,
                            height: width / 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1])
                    }
                    
                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[2],
                            width: width / 2,
                            height: width / 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 2), url: sources[2])
                        
                        ZStack {
                            MultiImageView(
                                source: sources[3],
                                width: width / 2,
                                height: width / 2
                            )
                            .withUploadingStateIndicator(for: uploadState(for: 3), url: sources[3])
                            
                            if notDisplayedImages > 0 {
                                Color.black.opacity(0.4)
                                
                                Text("+\(notDisplayedImages)")
                                    .foregroundColor(Color(colors.staticColorText))
                                    .font(fonts.title)
                            }
                        }
                        .frame(width: width / 2, height: width / 2)
                    }
                }
                .aspectRatio(1, contentMode: .fill)
            }
        }
        .frame(maxWidth: width)
    }
    
    private var notDisplayedImages: Int {
        sources.count > maxDisplayedImages ? sources.count - maxDisplayedImages : 0
    }
    
    private func uploadState(for index: Int) -> AttachmentUploadingState? {
        message.imageAttachments[index].uploadingState
    }
}

struct SingleImageView: View {
    let source: URL
    let width: CGFloat
    
    var body: some View {
        LazyLoadingImage(source: source, width: width)
            .frame(width: width, height: 3 * width / 4)
    }
}

struct MultiImageView: View {
    let source: URL
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        LazyLoadingImage(source: source, width: width)
            .frame(width: width, height: height)
            .clipped()
    }
}

struct LazyLoadingImage: View {
    @Injected(\.utils) var utils
    
    @State private var image: UIImage?
    @State private var error: Error?
    
    let source: URL
    let width: CGFloat
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else if error != nil {
                Color(.secondarySystemBackground)
            } else {
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            }
        }
        .onAppear {
            if image != nil {
                return
            }
            
            utils.imageLoader.loadImage(
                url: source,
                imageCDN: utils.imageCDN,
                resize: true,
                preferredSize: CGSize(width: width, height: 3 * width / 4),
                completion: { result in
                    switch result {
                    case let .success(image):
                        self.image = image
                    case let .failure(error):
                        self.error = error
                    }
                }
            )
        }
        .clipped()
    }
}
