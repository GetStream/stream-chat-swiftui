//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Nuke
import NukeUI
import StreamChat
import SwiftUI

public struct ImageAttachmentContainer: View {
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    let isGiphy: Bool
                
    public var body: some View {
        if message.text.isEmpty {
            ImageAttachmentView(
                message: message,
                width: width,
                isGiphy: isGiphy
            )
            .messageBubble(for: message, isFirst: isFirst)
        } else {
            VStack(spacing: 0) {
                if hasAttachments {
                    ImageAttachmentView(
                        message: message,
                        width: width,
                        isGiphy: isGiphy
                    )
                }

                HStack {
                    Text(message.text)
                        .standardPadding()
                    Spacer()
                }
            }
            .messageBubble(for: message, isFirst: isFirst)
        }
    }
    
    private var hasAttachments: Bool {
        isGiphy ? !message.giphyAttachments.isEmpty : !message.imageAttachments.isEmpty
    }
}

struct ImageAttachmentView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.utils) var utils
    
    let message: ChatMessage
    let width: CGFloat
    let isGiphy: Bool
    
    private let spacing: CGFloat = 2
    private let maxDisplayedImages = 4
    
    private var imageCDN: ImageCDN {
        utils.imageCDN
    }
    
    private var sources: [URL] {
        if isGiphy {
            return message.giphyAttachments.map { attachment in
                if let state = attachment.uploadingState {
                    return state.localFileURL
                } else {
                    let url = imageCDN.thumbnailURL(
                        originalURL: attachment.previewURL,
                        preferredSize: CGSize(width: width, height: width)
                    )
                    
                    return url
                }
            }
        } else {
            return message.imageAttachments.map { attachment in
                if let state = attachment.uploadingState {
                    return state.localFileURL
                } else {
                    return attachment.imagePreviewURL
                }
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
                        width: width / 2
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
                    
                    MultiImageView(
                        source: sources[1],
                        width: width / 2
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1])
                }
                .aspectRatio(1, contentMode: .fill)
            } else if sources.count == 3 {
                HStack(spacing: spacing) {
                    MultiImageView(
                        source: sources[0],
                        width: width / 2
                    )
                    .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
                    
                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[1],
                            width: width / 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1])
                        
                        MultiImageView(
                            source: sources[2],
                            width: width / 2
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
                            width: width / 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 0), url: sources[0])
                        
                        MultiImageView(
                            source: sources[1],
                            width: width / 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 1), url: sources[1])
                    }
                    
                    VStack(spacing: spacing) {
                        MultiImageView(
                            source: sources[2],
                            width: width / 2
                        )
                        .withUploadingStateIndicator(for: uploadState(for: 2), url: sources[2])
                        
                        ZStack {
                            MultiImageView(
                                source: sources[3],
                                width: width / 2
                            )
                            .withUploadingStateIndicator(for: uploadState(for: 3), url: sources[3])
                            
                            if notDisplayedImages > 0 {
                                Color.black.opacity(0.4)
                                
                                Text("+\(notDisplayedImages)")
                                    .foregroundColor(Color(colors.staticColorText))
                                    .font(fonts.title)
                            }
                        }
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
        if isGiphy {
            return message.giphyAttachments[index].uploadingState
        } else {
            return message.imageAttachments[index].uploadingState
        }
    }
}

struct SingleImageView: View {
    let source: URL
    let width: CGFloat
    
    var body: some View {
        LazyLoadingImage(source: source, width: width)
            .aspectRatio(contentMode: .fit)
    }
}

struct MultiImageView: View {
    let source: URL
    let width: CGFloat
    
    var body: some View {
        LazyLoadingImage(source: source, width: width)
            .frame(width: width)
    }
}

struct LazyLoadingImage: View {
    let source: URL
    let width: CGFloat
    
    var body: some View {
        LazyImage(source: source) { state in
            if let imageContainer = state.imageContainer {
                Image(imageContainer)
            } else if state.error != nil {
                Color(.secondarySystemBackground)
            } else {
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            }
        }
        .onDisappear(.reset)
        .processors([ImageProcessors.Resize(width: width)])
        .priority(.high)
    }
}
