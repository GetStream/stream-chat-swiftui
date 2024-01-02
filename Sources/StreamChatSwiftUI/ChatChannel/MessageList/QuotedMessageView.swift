//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

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
                    factory: factory,
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: fillAvailableSpace,
                    forceLeftToRight: forceLeftToRight
                )
            } else {
                QuotedMessageView(
                    factory: factory,
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
        .accessibilityIdentifier("QuotedMessageViewContainer")
    }
}

/// View for the quoted message.
public struct QuotedMessageView<Factory: ViewFactory>: View {

    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    
    private let attachmentWidth: CGFloat = 36

    public var factory: Factory
    public var quotedMessage: ChatMessage
    public var fillAvailableSpace: Bool
    public var forceLeftToRight: Bool
    
    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }

    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        forceLeftToRight: Bool
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        self.fillAvailableSpace = fillAvailableSpace
        self.forceLeftToRight = forceLeftToRight
    }

    public var body: some View {
        HStack(alignment: .top) {
            if !quotedMessage.attachmentCounts.isEmpty {
                ZStack {
                    if messageTypeResolver.hasCustomAttachment(message: quotedMessage) {
                        factory.makeCustomAttachmentQuotedView(for: quotedMessage)
                    } else if hasVoiceAttachments {
                        VoiceRecordingPreview(voiceAttachment: quotedMessage.voiceRecordingAttachments[0].payload)
                    } else if !quotedMessage.imageAttachments.isEmpty {
                        LazyLoadingImage(
                            source: quotedMessage.imageAttachments[0].imageURL,
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
                        LazyImage(
                            imageURL: quotedMessage.linkAttachments[0].previewURL ?? quotedMessage.linkAttachments[0]
                                .originalURL
                        )
                        .onDisappear(.cancel)
                        .processors([ImageProcessors.Resize(width: attachmentWidth)])
                        .priority(.high)
                    }
                }
                .frame(width: hasVoiceAttachments ? nil : attachmentWidth, height: attachmentWidth)
                .aspectRatio(1, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .allowsHitTesting(false)
            }

            Text(textForMessage)
                .foregroundColor(textColor(for: quotedMessage))
                .lineLimit(3)
                .font(fonts.footnote)
                .accessibility(identifier: "quotedMessageText")

            if fillAvailableSpace {
                Spacer()
            }
        }
        .id(quotedMessage.messageId)
        .padding(hasVoiceAttachments ? [.leading, .top, .bottom] : .all, 8)
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: quotedMessage,
                    isFirst: true,
                    injectedBackgroundColor: bubbleBackground,
                    cornerRadius: 12,
                    forceLeftToRight: forceLeftToRight
                )
            )
        )
        .accessibilityElement(children: .contain)
    }

    private var bubbleBackground: UIColor {
        if !quotedMessage.linkAttachments.isEmpty {
            return colors.highlightedAccentBackground1
        }

        var colors = colors
        let color = quotedMessage.isSentByCurrentUser ?
            colors.quotedMessageBackgroundCurrentUser : colors.quotedMessageBackgroundOtherUser
        return color
    }

    private func filePreviewImage(for url: URL) -> UIImage {
        let iconName = url.pathExtension
        return images.documentPreviews[iconName] ?? images.fileFallback
    }

    private var textForMessage: String {
        if !quotedMessage.text.isEmpty {
            return quotedMessage.adjustedText
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
    
    private var hasVoiceAttachments: Bool {
        !quotedMessage.voiceRecordingAttachments.isEmpty
    }
}

struct VoiceRecordingPreview: View {
    
    @Injected(\.images) var images
    @Injected(\.utils) var utils
    
    let voiceAttachment: VoiceRecordingAttachmentPayload
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(
                    utils.audioRecordingNameFormatter.title(
                        forItemAtURL: voiceAttachment.voiceRecordingURL,
                        index: 0
                    )
                )
                .bold()
                .lineLimit(1)
                
                RecordingDurationView(duration: voiceAttachment.duration ?? 0)
            }
            
            Spacer()
            
            Image(uiImage: images.fileAac)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 36)
        }
    }
}
