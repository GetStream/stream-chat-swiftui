//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The inner content of a message item: avatar, bubble, reactions, replies, and delivery status.
struct MessageContainerView<Factory: ViewFactory>: View {
    @ObservedObject var messageViewModel: MessageViewModel

    @Injected(\.utils) private var utils
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let channel: ChatChannel
    let message: ChatMessage
    let contentWidth: CGFloat
    let showsAllInfo: Bool
    let shownAsPreview: Bool
    let isLast: Bool
    @Binding var scrolledId: String?
    let onGesture: (_ showsMessageActions: Bool) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: tokens.spacingXs) {
            if !messageViewModel.isRightAligned
                && utils.messageListConfig.messageDisplayOptions.showAvatars(for: channel, incoming: true) {
                avatarView
            }

            VStack(
                alignment: messageViewModel.isRightAligned ? .trailing : .leading,
                spacing: tokens.spacingXxs
            ) {
                if messageViewModel.annotationsShown {
                    factory.makeMessageTopView(
                        options: MessageTopViewOptions(
                            message: message,
                            channel: channel,
                            messageViewModel: messageViewModel,
                            usesInvertedStyle: shownAsPreview
                        )
                    )
                    .accessibilityElement(children: .contain)
                }

                messageBubbleContent
                    .padding(
                        .top,
                        messageViewModel.topReactionsShown && messageViewModel.annotationsShown ? messageListConfig.messageDisplayOptions
                            .reactionsTopPadding(message) : 0
                    )
                    .accessibilityIdentifier("MessageView")
                    .environment(
                        \.messageCompositeAccessibilityLabel,
                        messageViewModel.captionAccessibilityLabel(showsAllInfo: showsAllInfo)
                    )

                if messageViewModel.threadRepliesShown {
                    factory.makeMessageRepliesView(
                        options: MessageRepliesViewOptions(
                            channel: channel,
                            message: message,
                            replyCount: message.replyCount,
                            usesInvertedStyle: shownAsPreview
                        )
                    )
                    .accessibilityElement(children: .contain)
                    .accessibility(identifier: "MessageRepliesView")
                }

                if messageViewModel.bottomReactionsShown {
                    factory.makeBottomReactionsView(
                        options: ReactionsBottomViewOptions(
                            message: message,
                            showsAllInfo: showsAllInfo,
                            onTap: {
                                onGesture(false)
                            },
                            onLongPress: {
                                onGesture(false)
                            }
                        )
                    )
                }

                // The timestamp and read indicator are always hidden from
                // VoiceOver - they are announced as part of the message bubble's
                // label instead - so they never become separate focus stops.
                if showsAllInfo {
                    deliveryStatusView
                        .accessibilityHidden(true)
                }
            }

            if messageViewModel.isRightAligned
                && utils.messageListConfig.messageDisplayOptions.showAvatars(for: channel, incoming: false) {
                avatarView
            }
        }
        .frame(maxWidth: .infinity, alignment: messageViewModel.isRightAligned ? .trailing : .leading)
        .padding(.top, messageViewModel.topReactionsShown && !messageViewModel.annotationsShown ? messageListConfig.messageDisplayOptions.reactionsTopPadding(message) : 0)
        .padding(.horizontal, messageListConfig.messagePaddings.horizontal)
        .padding(.bottom, showsAllInfo || messageViewModel.annotationsShown ? paddingValue : groupMessageInterItemSpacing)
        .padding(.top, isLast ? paddingValue : (messageViewModel.annotationsShown ? groupMessageInterItemSpacing : 0))
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var messageView: some View {
        MessageView(
            factory: factory,
            message: message,
            contentWidth: contentWidth,
            isFirst: showsAllInfo,
            scrolledId: $scrolledId,
            translationLanguage: messageViewModel.translationLanguage
        )
        .allowsHitTesting(!shownAsPreview)
    }

    /// The message bubble and its failure overlay, sized to hug the bubble
    /// content. Reactions are intentionally not included here so they stay a
    /// separate VoiceOver element next to the (possibly combined) bubble.
    @ViewBuilder
    private var bubbleView: some View {
        Group {
            if messageViewModel.usesScrollView {
                ScrollView {
                    messageView
                }
            } else {
                messageView
            }
        }
        .overlay(
            messageViewModel.failureIndicatorShown ? SendFailureIndicator() : nil
        )
    }

    @ViewBuilder
    private var reactionsOverlay: some View {
        if messageViewModel.topReactionsShown {
            factory.makeMessageReactionView(
                options: MessageReactionViewOptions(
                    message: message,
                    onTapGesture: {
                        onGesture(false)
                    },
                    onLongPressGesture: {
                        onGesture(false)
                    }
                )
            )
        }
    }

    @ViewBuilder
    private var messageBubbleContent: some View {
        bubbleView
            .accessibilityElement(
                children: messageViewModel.keepsBubbleAccessibilityChildrenFocusable ? .contain : .ignore
            )
            .accessibilityLabel(
                messageViewModel.keepsBubbleAccessibilityChildrenFocusable
                    ? "" : messageViewModel.accessibilityLabel(showsAllInfo: showsAllInfo)
            )
            // Applied after the accessibility element so reactions remain a separate
            // focusable element rather than being merged into the bubble.
            .overlay(
                reactionsOverlay,
                alignment: messageViewModel.isRightAligned ? .trailing : .leading
            )
            .frame(maxWidth: contentWidth, alignment: messageViewModel.isRightAligned ? .trailing : .leading)
    }

    @ViewBuilder
    private var avatarView: some View {
        factory.makeUserAvatarView(
            options: UserAvatarViewOptions(
                user: message.author,
                size: AvatarSize.medium,
                showsIndicator: false
            )
        )
        .opacity(isLast || showsAllInfo ? 1 : 0)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var deliveryStatusView: some View {
        if message.isSentByCurrentUser && channel.config.readEventsEnabled {
            HStack(spacing: tokens.spacingXxs) {
                factory.makeMessageReadIndicatorView(
                    options: MessageReadIndicatorViewOptions(
                        channel: channel,
                        message: message,
                        usesInvertedStyle: shownAsPreview
                    )
                )

                if messageViewModel.messageDateShown {
                    factory.makeMessageDateView(
                        options: MessageDateViewOptions(message: message, usesInvertedStyle: shownAsPreview)
                    )
                }
            }
            .padding(.bottom, tokens.spacingXxs)
        } else if messageViewModel.authorAndDateShown {
            factory.makeMessageAuthorAndDateView(
                options: MessageAuthorAndDateViewOptions(message: message, usesInvertedStyle: shownAsPreview)
            )
            .padding(.bottom, tokens.spacingXxs)
        } else if messageViewModel.messageDateShown {
            factory.makeMessageDateView(
                options: MessageDateViewOptions(message: message, usesInvertedStyle: shownAsPreview)
            )
            .padding(.bottom, tokens.spacingXxs)
        }
    }

    // MARK: - Computed Properties

    private var paddingValue: CGFloat {
        messageListConfig.messagePaddings.singleBottom
    }

    private var groupMessageInterItemSpacing: CGFloat {
        messageListConfig.messagePaddings.groupBottom
    }

    private var messageListConfig: MessageListConfig {
        utils.messageListConfig
    }
}

/// The composite VoiceOver label (sender, content, time and delivery status)
/// that a message's content should announce, so that focusing nested content
/// (such as an attachment caption) reads the same thing as a message without
/// attachments. `nil` when the surrounding message cell provides no composite
/// label.
///
/// This value is passed through the SwiftUI `Environment` instead of through
/// view initializers because it would otherwise need to be threaded through
/// four layers of public API (`MessageView` → `MessageAttachmentsView` →
/// `AttachmentTextViewOptions` / factory → `AttachmentTextView`). The
/// Environment avoids adding parameters to every intermediate type for a
/// concern that only the leaf view consumes.
struct MessageCompositeAccessibilityLabelKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var messageCompositeAccessibilityLabel: String? {
        get { self[MessageCompositeAccessibilityLabelKey.self] }
        set { self[MessageCompositeAccessibilityLabelKey.self] = newValue }
    }
}
