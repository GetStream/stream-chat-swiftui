//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Applies attachment container styling.
///
/// Use this view modifier for customising individual attachment views.
/// - SeeAlso: ``Styles/makeMessageAttachmentItemViewModifier(options:)->ViewModifier``
public struct AttachmentContainerViewModifier: ViewModifier {
    let bubbleInsets: EdgeInsets
    let backgroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let corners: UIRectCorner

    public init(
        bubbleInsets: EdgeInsets,
        backgroundColor: Color,
        borderColor: Color?,
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat,
        corners: UIRectCorner
    ) {
        self.bubbleInsets = bubbleInsets
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.corners = corners
    }

    public func body(content: Content) -> some View {
        content
            .padding(bubbleInsets)
            .background(backgroundColor)
            .overlay(borderOverlay)
            .clipShape(shape)
    }

    private var shape: BubbleBackgroundShape {
        BubbleBackgroundShape(
            cornerRadius: cornerRadius,
            corners: corners
        )
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if let borderColor {
            shape.stroke(borderColor, lineWidth: borderWidth)
        }
    }
}

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
        !options.message.hasSingleMediaAttachmentWithoutCaption
    }

    private var bubbleInsets: EdgeInsets {
        guard isBubbleShown else { return EdgeInsets() }
        // Single voice and file don't have extra padding.
        if options.message.hasSingleFileOrVoiceAttachmentWithoutCaption {
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
            content.modifier(AttachmentContainerViewModifier(
                bubbleInsets: EdgeInsets(),
                backgroundColor: defaultAttachmentBackgroundColor,
                borderColor: Color(colors.borderCoreDefault),
                cornerRadius: tokens.messageBubbleRadiusAttachment,
                corners: attachmentCorners(isSingleWithoutCaption: options.message.isSingleFileWithoutCaption)
            ))
        case .some(.voiceRecording):
            // A voice recording quoted without a caption renders flat inside the message bubble.
            if isVoiceRecordingContainerShown {
                content.modifier(AttachmentContainerViewModifier(
                    bubbleInsets: EdgeInsets(
                        top: tokens.spacingXs,
                        leading: tokens.spacingXs,
                        bottom: tokens.spacingXs,
                        trailing: tokens.spacingXs
                    ),
                    backgroundColor: defaultAttachmentBackgroundColor,
                    borderColor: Color(colors.borderCoreDefault),
                    cornerRadius: tokens.messageBubbleRadiusAttachment,
                    corners: attachmentCorners(isSingleWithoutCaption: options.message.isSingleVoiceWithoutCaption)
                ))
            } else {
                content
            }
        case .some(.linkPreview):
            content.modifier(AttachmentContainerViewModifier(
                bubbleInsets: EdgeInsets(),
                backgroundColor: defaultAttachmentBackgroundColor,
                borderColor: Color(colors.borderCoreDefault),
                cornerRadius: tokens.messageBubbleRadiusAttachment,
                corners: .allCorners
            ))
        case .some(.image), .some(.video):
            content.modifier(AttachmentContainerViewModifier(
                bubbleInsets: EdgeInsets(),
                backgroundColor: .clear,
                borderColor: options.message.hasSingleMediaAttachmentWithoutCaption
                    ? options.message.bubbleBorder(colors: colors)
                    : nil,
                cornerRadius: mediaCornerRadius,
                corners: attachmentCorners(isSingleWithoutCaption: options.message.hasSingleMediaAttachmentWithoutCaption)
            ))
        case .none:
            content.modifier(AttachmentContainerViewModifier(
                bubbleInsets: EdgeInsets(),
                backgroundColor: defaultAttachmentBackgroundColor,
                borderColor: nil,
                cornerRadius: tokens.messageBubbleRadiusAttachment,
                corners: .allCorners
            ))
        default:
            // Other attachment types (e.g. giphy, audio, custom) are not wrapped in a container bubble.
            content
        }
    }

    private var defaultAttachmentBackgroundColor: Color {
        // Single file and voice attachments are rendered in a bubble, but the attachment itself does not have an additional darker background.
        if options.message.hasSingleFileOrVoiceAttachmentWithoutCaption {
            return .clear
        }
        return Color(options.message.isSentByCurrentUser ? colors.chatBackgroundAttachmentOutgoing : colors.chatBackgroundAttachmentIncoming)
    }

    private var mediaCornerRadius: CGFloat {
        options.message.hasSingleMediaAttachmentWithoutCaption
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
    var hasSingleMediaAttachmentWithCaption: Bool {
        guard !text.isEmpty, quotedMessage == nil else { return false }
        return attachmentCounts.count == 1 && (attachmentCounts[.image] == 1 || attachmentCounts[.video] == 1)
    }

    fileprivate var hasSingleFileOrVoiceAttachmentWithoutCaption: Bool {
        guard text.isEmpty, quotedMessage == nil else { return false }
        return attachmentCounts.count == 1 && (attachmentCounts[.file] == 1 || attachmentCounts[.voiceRecording] == 1)
    }

    fileprivate var hasSingleMediaAttachmentWithoutCaption: Bool {
        guard text.isEmpty, quotedMessage == nil else { return false }
        return attachmentCounts.count == 1 && (attachmentCounts[.image] == 1 || attachmentCounts[.video] == 1)
    }

    fileprivate var isSingleFileWithoutCaption: Bool {
        text.isEmpty && fileAttachments.count == 1
    }

    fileprivate var isSingleVoiceWithoutCaption: Bool {
        text.isEmpty && voiceRecordingAttachments.count == 1
    }
}
