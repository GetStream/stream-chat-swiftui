//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Nuke
import NukeUI
import StreamChat
import SwiftUI

struct QuotedMessageViewContainer: View {
    
    private let avatarSize: CGFloat = 24
    
    var quotedMessage: ChatMessage
    var message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom) {
            if !message.isSentByCurrentUser {
                MessageAvatarView(
                    author: quotedMessage.author,
                    size: .init(width: avatarSize, height: avatarSize)
                )
                
                QuotedMessageView(
                    quotedMessage: quotedMessage,
                    message: message
                )
            } else {
                QuotedMessageView(
                    quotedMessage: quotedMessage,
                    message: message
                )
                
                MessageAvatarView(
                    author: quotedMessage.author,
                    size: .init(width: avatarSize, height: avatarSize)
                )
            }
        }
        .padding()
    }
}

struct QuotedMessageView: View {
    
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    private let attachmentWidth: CGFloat = 36
    
    var quotedMessage: ChatMessage
    var message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                if !quotedMessage.imageAttachments.isEmpty {
                    LazyLoadingImage(
                        source: quotedMessage.imageAttachments[0].imagePreviewURL,
                        width: attachmentWidth,
                        resize: false
                    )
                } else if !quotedMessage.giphyAttachments.isEmpty {
                    LazyGiphyView(
                        source: quotedMessage.giphyAttachments[0].previewURL,
                        width: attachmentWidth
                    )
                } else if !quotedMessage.fileAttachments.isEmpty {
                    Image(uiImage: filePreviewImage(for: quotedMessage.fileAttachments[0].assetURL))
                } else if !quotedMessage.videoAttachments.isEmpty {
                    VideoAttachmentView(
                        attachment: quotedMessage.videoAttachments[0],
                        message: quotedMessage,
                        width: attachmentWidth
                    )
                } else if !quotedMessage.linkAttachments.isEmpty {
                    LazyImage(source: quotedMessage.linkAttachments[0].previewURL!)
                        .onDisappear(.reset)
                        .processors([ImageProcessors.Resize(width: attachmentWidth)])
                        .priority(.high)
                }
            }
            .frame(width: attachmentWidth, height: attachmentWidth)
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(textForMessage)
                .lineLimit(3)
                .font(fonts.footnote)
            
            if !message.attachmentCounts.isEmpty {
                Spacer()
            }
        }
        .padding(.all, 8)
        .messageBubble(
            for: quotedMessage,
            isFirst: true,
            backgroundColor: bubbleBackground,
            cornerRadius: 12
        )
    }
    
    private var bubbleBackground: UIColor {
        if !quotedMessage.linkAttachments.isEmpty {
            return colors.highlightedAccentBackground1
        }
        
        return colors.background8
    }
    
    private func filePreviewImage(for url: URL) -> UIImage {
        let iconName = url.pathExtension
        return images.documentPreviews[iconName] ?? images.fileFallback
    }
    
    private var textForMessage: String {
        if !quotedMessage.text.isEmpty {
            return quotedMessage.text
        }
        
        if !quotedMessage.imageAttachments.isEmpty {
            return "Photo"
        } else if !quotedMessage.giphyAttachments.isEmpty {
            return "Giphy"
        } else if !quotedMessage.fileAttachments.isEmpty {
            return quotedMessage.fileAttachments[0].title ?? "File"
        } else if !quotedMessage.videoAttachments.isEmpty {
            return "Video"
        } else if !quotedMessage.linkAttachments.isEmpty {
            return "Link"
        }
        
        return "Unknown"
    }
}
