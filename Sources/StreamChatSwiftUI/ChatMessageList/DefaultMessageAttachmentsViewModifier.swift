//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default view modifier used by ``Styles/makeMessageAttachmentsViewModifier(options:)``.
struct DefaultMessageAttachmentsViewModifier<Style: Styles>: ViewModifier {
    @Injected(\.tokens) private var tokens

    let styles: Style
    let options: MessageAttachmentsViewModifierOptions

    init(
        styles: Style,
        options: MessageAttachmentsViewModifierOptions
    ) {
        self.styles = styles
        self.options = options
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if isBubbleShown {
            content
                .padding(bubbleInsets)
                .modifier(styles.makeMessageViewModifier(
                    for: MessageModifierInfo(
                        message: options.message,
                        isFirst: options.isFirst
                    )
                ))
        } else {
            content
        }
    }

    private var isBubbleShown: Bool {
        !options.message.hasSingleAttachment(of: [.image, .video], captioned: false)
    }

    private var bubbleInsets: EdgeInsets {
        guard isBubbleShown else { return EdgeInsets() }
        // Single voice and file don't have extra padding.
        if options.message.hasSingleAttachment(of: [.file, .voiceRecording], captioned: false) {
            return EdgeInsets()
        }
        return EdgeInsets(
            top: tokens.spacingXs,
            leading: tokens.spacingXs,
            bottom: tokens.spacingXs,
            trailing: tokens.spacingXs
        )
    }
}

/// Default view modifier used by ``Styles/makeMessageAttachmentItemViewModifier(options:)``.
struct DefaultMessageAttachmentItemViewModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils
    @Environment(\.layoutDirection) private var layoutDirection

    let options: MessageAttachmentItemViewModifierOptions

    init(options: MessageAttachmentItemViewModifierOptions) {
        self.options = options
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        switch options.attachmentType {
        case .some(.file):
            content.modifier(BubbleModifier(
                corners: attachmentCorners(isSingleWithoutCaption: options.message.hasSingleAttachment(of: [.file], captioned: false)),
                backgroundColors: [defaultAttachmentBackgroundColor],
                borderColor: Color(colors.borderCoreDefault),
                cornerRadius: tokens.messageBubbleRadiusAttachment,
                contentInsets: EdgeInsets()
            ))
        case .some(.voiceRecording):
            // A voice recording quoted without a caption renders flat inside the message bubble.
            if isVoiceRecordingContainerShown {
                content.modifier(BubbleModifier(
                    corners: attachmentCorners(isSingleWithoutCaption: options.message.hasSingleAttachment(of: [.voiceRecording], captioned: false)),
                    backgroundColors: [defaultAttachmentBackgroundColor],
                    borderColor: Color(colors.borderCoreDefault),
                    cornerRadius: tokens.messageBubbleRadiusAttachment,
                    contentInsets: EdgeInsets(
                        top: tokens.spacingXs,
                        leading: tokens.spacingXs,
                        bottom: tokens.spacingXs,
                        trailing: tokens.spacingXs
                    )
                ))
            } else {
                content
            }
        case .some(.linkPreview):
            content.modifier(BubbleModifier(
                corners: .allCorners,
                backgroundColors: [defaultAttachmentBackgroundColor],
                borderColor: Color(colors.borderCoreDefault),
                cornerRadius: tokens.messageBubbleRadiusAttachment,
                contentInsets: EdgeInsets()
            ))
        case .some(.image), .some(.video):
            content.modifier(BubbleModifier(
                corners: attachmentCorners(isSingleWithoutCaption: options.message.hasSingleAttachment(of: [.image, .video], captioned: false)),
                backgroundColors: [.clear],
                borderColor: options.message.hasSingleAttachment(of: [.image, .video], captioned: false)
                    ? options.message.bubbleBorder(colors: colors)
                    : nil,
                cornerRadius: mediaCornerRadius,
                contentInsets: EdgeInsets()
            ))
        case .none:
            content.modifier(BubbleModifier(
                corners: .allCorners,
                backgroundColors: [defaultAttachmentBackgroundColor],
                borderColor: nil,
                cornerRadius: tokens.messageBubbleRadiusAttachment,
                contentInsets: EdgeInsets()
            ))
        default:
            // Other attachment types (e.g. giphy, audio, custom) are not wrapped in a container bubble.
            content
        }
    }

    private var defaultAttachmentBackgroundColor: Color {
        // Single file and voice attachments are rendered in a bubble, but the attachment itself does not have an additional darker background.
        if options.message.hasSingleAttachment(of: [.file, .voiceRecording], captioned: false) {
            return .clear
        }
        return Color(options.message.isSentByCurrentUser ? colors.chatBackgroundAttachmentOutgoing : colors.chatBackgroundAttachmentIncoming)
    }

    private var mediaCornerRadius: CGFloat {
        options.message.hasSingleAttachment(of: [.image, .video], captioned: false)
            ? tokens.messageBubbleRadiusGroupBottom
            : tokens.messageBubbleRadiusAttachment
    }

    private var isVoiceRecordingContainerShown: Bool {
        !(options.message.quotedMessage != nil && options.message.text.isEmpty)
    }

    private func attachmentCorners(isSingleWithoutCaption: Bool) -> UIRectCorner {
        options.isFirst && isSingleWithoutCaption
            ? options.message.bubbleCorners(
                isFirst: options.isFirst,
                forceLeftToRight: utils.messageListConfig.messageListAlignment == .leftAligned,
                layoutDirection: layoutDirection
            )
            : .allCorners
    }
}

extension ChatMessage {
    func hasSingleAttachment(of types: Set<AttachmentType>, captioned: Bool) -> Bool {
        guard quotedMessage == nil else { return false }
        guard captioned ? !text.isEmpty : text.isEmpty else { return false }
        return attachmentCounts.count == 1 && types.contains { attachmentCounts[$0] == 1 }
    }
}
