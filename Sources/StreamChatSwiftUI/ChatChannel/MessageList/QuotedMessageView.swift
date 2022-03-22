//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Nuke
import NukeUI
import StreamChat
import SwiftUI

/// Container showing the quoted message view with the user avatar.
struct QuotedMessageViewContainer<Factory: ViewFactory>: View {
    
    @Injected(\.utils) private var utils
    
    private let avatarSize: CGFloat = 24
    
    var factory: Factory
    var quotedMessage: ChatMessage
    var fillAvailableSpace: Bool
    var forceLeftToRight = false
    @Binding var scrolledId: String?
    
    var body: some View {
        HStack(alignment: .bottom) {
            if !quotedMessage.isSentByCurrentUser || forceLeftToRight {
                factory.makeQuotedMessageAvatarView(
                    for: utils.messageCachingUtils.authorInfo(from: quotedMessage),
                    size: CGSize(width: avatarSize, height: avatarSize)
                )
                
                QuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: fillAvailableSpace,
                    forceLeftToRight: forceLeftToRight
                )
            } else {
                QuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: fillAvailableSpace,
                    forceLeftToRight: forceLeftToRight
                )
                
                factory.makeQuotedMessageAvatarView(
                    for: utils.messageCachingUtils.authorInfo(from: quotedMessage),
                    size: CGSize(width: avatarSize, height: avatarSize)
                )
            }
        }
        .padding(.all, 8)
        .onTapGesture(perform: {
            scrolledId = quotedMessage.messageId
        })
    }
}

/// View for the quoted message.
struct QuotedMessageView: View {
    
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    private let attachmentWidth: CGFloat = 36
    
    var quotedMessage: ChatMessage
    var fillAvailableSpace: Bool
    var forceLeftToRight: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            if !quotedMessage.attachmentCounts.isEmpty {
                ZStack {
                    if !quotedMessage.imageAttachments.isEmpty {
                        LazyLoadingImage(
                            source: quotedMessage.imageAttachments[0].imagePreviewURL,
                            width: attachmentWidth,
                            height: attachmentWidth,
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
                            width: attachmentWidth,
                            ratio: 1.0,
                            cornerRadius: 0
                        )
                    } else if !quotedMessage.linkAttachments.isEmpty {
                        LazyImage(source: quotedMessage.linkAttachments[0].previewURL!)
                            .onDisappear(.cancel)
                            .processors([ImageProcessors.Resize(width: attachmentWidth)])
                            .priority(.high)
                    }
                }
                .frame(width: attachmentWidth, height: attachmentWidth)
                .aspectRatio(1, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .allowsHitTesting(false)
            }
            
            Text(textForMessage)
                .lineLimit(3)
                .font(fonts.footnote)
            
            if fillAvailableSpace {
                Spacer()
            }
        }
        .id(quotedMessage.messageId)
        .padding(.all, 8)
        .messageBubble(
            for: quotedMessage,
            isFirst: true,
            backgroundColor: bubbleBackground,
            cornerRadius: 12,
            forceLeftToRight: forceLeftToRight
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
            return L10n.Composer.Quoted.photo
        } else if !quotedMessage.giphyAttachments.isEmpty {
            return L10n.Composer.Quoted.giphy
        } else if !quotedMessage.fileAttachments.isEmpty {
            return quotedMessage.fileAttachments[0].title ?? ""
        } else if !quotedMessage.videoAttachments.isEmpty {
            return L10n.Composer.Quoted.video
        }
        
        return ""
    }
}
