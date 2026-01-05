//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Container showing the quoted message view with the user avatar.
public struct QuotedMessageViewContainer<Factory: ViewFactory>: View {
    public var factory: Factory
    public var quotedMessage: ChatMessage
    public var fillAvailableSpace: Bool
    public var forceLeftToRight: Bool
    @Binding public var scrolledId: String?
    public let attachmentSize: CGSize
    public let quotedAuthorAvatarSize: CGSize

    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        forceLeftToRight: Bool = false,
        scrolledId: Binding<String?>,
        attachmentSize: CGSize = CGSize(width: 36, height: 36),
        quotedAuthorAvatarSize: CGSize = CGSize(width: 24, height: 24)
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        self.fillAvailableSpace = fillAvailableSpace
        self.forceLeftToRight = forceLeftToRight
        _scrolledId = scrolledId
        self.attachmentSize = attachmentSize
        self.quotedAuthorAvatarSize = quotedAuthorAvatarSize
    }

    public var body: some View {
        HStack(alignment: .bottom) {
            if !quotedMessage.isSentByCurrentUser || forceLeftToRight {
                factory.makeQuotedMessageAvatarView(
                    for: quotedMessage.authorDisplayInfo,
                    size: quotedAuthorAvatarSize
                )

                QuotedMessageView(
                    factory: factory,
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: fillAvailableSpace,
                    forceLeftToRight: forceLeftToRight,
                    attachmentSize: attachmentSize
                )
            } else {
                QuotedMessageView(
                    factory: factory,
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: fillAvailableSpace,
                    forceLeftToRight: forceLeftToRight,
                    attachmentSize: attachmentSize
                )

                factory.makeQuotedMessageAvatarView(
                    for: quotedMessage.authorDisplayInfo,
                    size: quotedAuthorAvatarSize
                )
            }
        }
        .padding(.all, 8)
        .onTapGesture(perform: {
            scrolledId = quotedMessage.messageId
        })
        .accessibilityAction {
            scrolledId = quotedMessage.messageId
        }
        .accessibilityIdentifier("QuotedMessageViewContainer")
    }
}

/// View for the quoted message.
public struct QuotedMessageView<Factory: ViewFactory>: View {
    @Environment(\.channelTranslationLanguage) var translationLanguage

    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    public var factory: Factory
    public var quotedMessage: ChatMessage
    public var fillAvailableSpace: Bool
    public var forceLeftToRight: Bool
    public let attachmentSize: CGSize

    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }

    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        forceLeftToRight: Bool,
        attachmentSize: CGSize = CGSize(width: 36, height: 36)
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        self.fillAvailableSpace = fillAvailableSpace
        self.forceLeftToRight = forceLeftToRight
        self.attachmentSize = attachmentSize
    }

    public var body: some View {
        HStack(alignment: .top) {
            factory.makeQuotedMessageContentView(
                options: QuotedMessageContentViewOptions(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: fillAvailableSpace,
                    attachmentSize: attachmentSize
                )
            )
        }
        .id(quotedMessage.messageId)
        .padding(
            hasVoiceAttachments ? [.leading, .top, .bottom] : .all, utils.messageListConfig.messagePaddings.quotedViewPadding
        )
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
    
    private var hasVoiceAttachments: Bool {
        !quotedMessage.voiceRecordingAttachments.isEmpty
    }
}

/// Options for configuring the quoted message content view.
public struct QuotedMessageContentViewOptions {
    /// The quoted message to display.
    public let quotedMessage: ChatMessage
    /// Whether the quoted container should take all the available space.
    public let fillAvailableSpace: Bool
    /// The size of the attachment preview.
    public let attachmentSize: CGSize

    public init(
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        attachmentSize: CGSize = CGSize(width: 36, height: 36)
    ) {
        self.quotedMessage = quotedMessage
        self.fillAvailableSpace = fillAvailableSpace
        self.attachmentSize = attachmentSize
    }
}

/// The quoted message content view.
///
/// It is the view that is embedded in quoted message bubble view.
public struct QuotedMessageContentView<Factory: ViewFactory>: View {
    @Environment(\.channelTranslationLanguage) var translationLanguage

    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    public var factory: Factory
    public var options: QuotedMessageContentViewOptions
    
    private var quotedMessage: ChatMessage {
        options.quotedMessage
    }

    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }

    public init(
        factory: Factory,
        options: QuotedMessageContentViewOptions
    ) {
        self.factory = factory
        self.options = options
    }

    public var body: some View {
        if !quotedMessage.attachmentCounts.isEmpty {
            ZStack {
                if messageTypeResolver.hasCustomAttachment(message: quotedMessage) {
                    factory.makeCustomAttachmentQuotedView(for: quotedMessage)
                } else if hasVoiceAttachments {
                    VoiceRecordingPreview(voiceAttachment: quotedMessage.voiceRecordingAttachments[0].payload)
                } else if !quotedMessage.imageAttachments.isEmpty {
                    LazyLoadingImage(
                        source: MediaAttachment(url: quotedMessage.imageAttachments[0].imageURL, type: .image),
                        width: options.attachmentSize.width,
                        height: options.attachmentSize.height,
                        resize: false
                    )
                } else if !quotedMessage.giphyAttachments.isEmpty {
                    LazyGiphyView(
                        source: quotedMessage.giphyAttachments[0].previewURL,
                        width: options.attachmentSize.width
                    )
                } else if !quotedMessage.fileAttachments.isEmpty {
                    Image(uiImage: filePreviewImage(for: quotedMessage.fileAttachments[0].assetURL))
                } else if !quotedMessage.videoAttachments.isEmpty {
                    VideoAttachmentView(
                        attachment: quotedMessage.videoAttachments[0],
                        message: quotedMessage,
                        width: options.attachmentSize.width,
                        ratio: 1.0,
                        cornerRadius: 0
                    )
                } else if !quotedMessage.linkAttachments.isEmpty {
                    LazyImage(
                        imageURL: quotedMessage.linkAttachments[0].previewURL ?? quotedMessage.linkAttachments[0]
                            .originalURL
                    )
                    .onDisappear(.cancel)
                    .processors([ImageProcessors.Resize(width: options.attachmentSize.width)])
                    .priority(.high)
                }
            }
            .frame(width: hasVoiceAttachments ? nil : options.attachmentSize.width, height: options.attachmentSize.height)
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .allowsHitTesting(false)
        } else if let poll = quotedMessage.poll, !quotedMessage.isDeleted {
            Text("📊 \(poll.name)")
        }

        if !hasVoiceAttachments {
            Text(textForMessage)
                .foregroundColor(textColor(for: quotedMessage))
                .lineLimit(3)
                .font(fonts.footnote)
                .accessibility(identifier: "quotedMessageText")
        }

        if options.fillAvailableSpace {
            Spacer()
        }
    }

    private func filePreviewImage(for url: URL) -> UIImage {
        let iconName = url.pathExtension
        return images.documentPreviews[iconName] ?? images.fileFallback
    }

    private var textForMessage: String {
        let translatedTextContent = quotedMessage.textContent(for: translationLanguage)
        let textContent = translatedTextContent ?? quotedMessage.textContent ?? ""
        
        if !textContent.isEmpty {
            return textContent
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
