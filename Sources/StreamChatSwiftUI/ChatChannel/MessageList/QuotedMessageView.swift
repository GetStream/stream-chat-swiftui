//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Container showing the quoted message view.
public struct QuotedMessageViewContainer<Factory: ViewFactory>: View {
    public var factory: Factory
    public var quotedMessage: ChatMessage
    public var fillAvailableSpace: Bool
    @Binding public var scrolledId: String?
    public let attachmentSize: CGSize

    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        scrolledId: Binding<String?>,
        attachmentSize: CGSize = CGSize(width: 36, height: 36)
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        self.fillAvailableSpace = fillAvailableSpace
        _scrolledId = scrolledId
        self.attachmentSize = attachmentSize
    }

    public var body: some View {
        HStack(alignment: .bottom) {
            QuotedMessageView(
                factory: factory,
                quotedMessage: quotedMessage,
                fillAvailableSpace: fillAvailableSpace,
                attachmentSize: attachmentSize
            )
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
    public let attachmentSize: CGSize

    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }

    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        attachmentSize: CGSize = CGSize(width: 36, height: 36)
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        self.fillAvailableSpace = fillAvailableSpace
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
        .padding(.all, utils.messageListConfig.messagePaddings.quotedViewPadding)
        .accessibilityElement(children: .contain)
    }

    private var bubbleBackground: UIColor {
        if !quotedMessage.linkAttachments.isEmpty {
            return colors.highlightedAccentBackground1
        }

        let color = quotedMessage.isSentByCurrentUser ?
            colors.quotedMessageBackgroundCurrentUser : colors.quotedMessageBackgroundOtherUser
        return color
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
                    factory.makeCustomAttachmentQuotedView(options: .init(message: quotedMessage))
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
                    ) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
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

struct ChatQuotedMessageView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
    @Injected(\.tokens) var tokens

    let title: String
    let subtitle: String
    let subtitleIcon: UIImage?
    let isSentByCurrentUser: Bool

    init(
        title: String,
        subtitle: String,
        subtitleIcon: UIImage? = nil,
        isSentByCurrentUser: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleIcon = subtitleIcon
        self.isSentByCurrentUser = isSentByCurrentUser
    }

    var body: some View {
        HStack(spacing: tokens.spacingXs) {
            QuoteIndicatorView(
                tintColor: isSentByCurrentUser
                    ? colors.chatReplyIndicatorOutgoing
                    : colors.chatReplyIndicatorIncoming
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(fonts.subheadlineBold)
                    .foregroundColor(Color(colors.chatTextMessage))
                    .lineLimit(1)

                HStack(spacing: tokens.spacingXxs) {
                    if let subtitleIcon {
                        Image(uiImage: subtitleIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: tokens.iconSizeXs,
                                height: tokens.iconSizeXs
                            )
                    }

                    Text(subtitle)
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.chatTextMessage))
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .modifier(QuotedMessageViewBackgroundModifier(
            isSentByCurrentUser: isSentByCurrentUser
        ))
    }
}

struct QuotedMessageViewBackgroundModifier: ViewModifier {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

    let isSentByCurrentUser: Bool
    let horizontalPadding: CGFloat?
    let verticalPadding: CGFloat?

    init(
        isSentByCurrentUser: Bool,
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil
    ) {
        self.isSentByCurrentUser = isSentByCurrentUser
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding ?? tokens.spacingXs)
            .padding(.vertical, verticalPadding ?? tokens.spacingXs)
            .background(
                RoundedRectangle(
                    cornerRadius: tokens.messageBubbleRadiusAttachment,
                    style: .continuous
                )
                .fill(Color(
                    isSentByCurrentUser
                        ? colors.chatBackgroundOutgoing
                        : colors.chatBackgroundIncoming
                ))
            )
    }
}

struct QuoteIndicatorView: View {
    let tintColor: UIColor

    var body: some View {
        Rectangle()
            .fill(Color(tintColor))
            .frame(width: 2)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .accessibilityIdentifier("QuoteIndicatorView")
    }
}

// MARK: - Dismiss button overlay

/// Overlays a close button on the top‑trailing corner of the view.
struct DismissButtonOverlayModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.images) private var images

    let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    func body(content: Content) -> some View {
        content.overlay(
            dismissButton,
            alignment: .topTrailing
        )
    }

    private var dismissButton: some View {
        Button(action: onDismiss) {
            Image(uiImage: images.overlayDismissIcon)
                .renderingMode(.template)
                .foregroundColor(Color(colors.controlRemoveControlIcon))
                .frame(
                    width: tokens.iconSizeMd,
                    height: tokens.iconSizeMd
                )
                .background(Color(colors.controlRemoveControlBackground))
                .clipShape(Circle())
                .contentShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(colors.controlRemoveControlBorder), lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .offset(x: dismissButtonOverlap, y: -dismissButtonOverlap)
        .accessibilityLabel(L10n.Composer.Quoted.dismiss)
        .accessibilityIdentifier("DismissButtonOverlay")
    }

    private var dismissButtonOverlap: CGFloat {
        tokens.spacingXxs
    }
}

extension View {
    /// Overlays a close button on the top‑trailing corner of the view.
    func dismissButtonOverlayModifier(onDismiss: @escaping () -> Void) -> some View {
        modifier(DismissButtonOverlayModifier(onDismiss: onDismiss))
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Outgoing").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I think this one could work. Took a short clip…",
                isSentByCurrentUser: true
            )
            .frame(maxHeight: 56)

            Text("In composer (with close button)").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I took a short clip earlier",
                subtitleIcon: Appearance().images.attachmentVideoIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)
            .dismissButtonOverlayModifier(onDismiss: {})

            Text("Incoming").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I think this one could work. Took a short clip…",
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Link").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Looks cozy, right? https://bloomh...",
                subtitleIcon: Appearance().images.attachmentLinkIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Image - Single").font(.title3).bold()

            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I think this one could work. Took a short clip…",
                subtitleIcon: Appearance().images.attachmentImageIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Image - Single - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Photo",
                subtitleIcon: Appearance().images.attachmentImageIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Image - Multiple").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I love these mountains",
                subtitleIcon: Appearance().images.attachmentImageIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Image - Multiple - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "6 photos",
                subtitleIcon: Appearance().images.attachmentImageIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Video - Single").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I took a short clip earlier",
                subtitleIcon: Appearance().images.attachmentVideoIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Video - Single - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Video",
                subtitleIcon: Appearance().images.attachmentVideoIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Video - Multiple").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I took some videos today",
                subtitleIcon: Appearance().images.attachmentVideoIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Video - Multiple - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "6 videos",
                subtitleIcon: Appearance().images.attachmentVideoIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Mixed").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I'm sending you some photos and files",
                subtitleIcon: Appearance().images.attachmentDocIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Mixed - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "6 files",
                subtitleIcon: Appearance().images.attachmentDocIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Voice Recording").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I took a short voice message",
                subtitleIcon: Appearance().images.attachmentVoiceIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Voice Recording - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Voice message (0:12)",
                subtitleIcon: Appearance().images.attachmentVoiceIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("File").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Here is the Q4 report",
                subtitleIcon: Appearance().images.attachmentDocIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("File - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "bloom-and-harbor-cafe-menu-su...",
                subtitleIcon: Appearance().images.attachmentDocIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Poll").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Where should we host the next team offsite...",
                subtitleIcon: Appearance().images.attachmentPollIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Spacer()
        }
        .padding()
    }
}

// TODO: Move to common module

import StreamChatCommonUI

extension Appearance.Images {
    var overlayDismissIcon: UIImage {
        UIImage(
            systemName: "xmark",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 10,
                weight: .heavy
            )
        )!
    }

    var attachmentImageIcon: UIImage {
        UIImage(
            systemName: "camera",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentLinkIcon: UIImage {
        UIImage(
            systemName: "link",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentVideoIcon: UIImage {
        UIImage(
            systemName: "video",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentDocIcon: UIImage {
        UIImage(
            systemName: "document",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentVoiceIcon: UIImage {
        UIImage(
            systemName: "microphone",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }

    var attachmentPollIcon: UIImage {
        UIImage(
            systemName: "chart.bar",
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )!
    }
}
