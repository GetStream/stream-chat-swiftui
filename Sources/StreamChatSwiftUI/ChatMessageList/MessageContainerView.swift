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
                }

                messageBubbleContent
                    .padding(
                        .top,
                        messageViewModel.topReactionsShown && messageViewModel.annotationsShown ? messageListConfig.messageDisplayOptions
                            .reactionsTopPadding(message) : 0
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("MessageView")

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

                if showsAllInfo {
                    deliveryStatusView
                }
            }

            if messageViewModel.isRightAligned
                && utils.messageListConfig.messageDisplayOptions.showAvatars(for: channel, incoming: false) {
                avatarView
            }
        }
        .frame(maxWidth: .infinity, alignment: messageViewModel.isRightAligned ? .trailing : .leading)
        .padding(.top, messageViewModel.topReactionsShown && !messageViewModel.isPinned ? messageListConfig.messageDisplayOptions.reactionsTopPadding(message) : 0)
        .padding(.horizontal, messageListConfig.messagePaddings.horizontal)
        .padding(.bottom, showsAllInfo || messageViewModel.annotationsShown ? paddingValue : groupMessageInterItemSpacing)
        .padding(.top, isLast ? paddingValue : 0)
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var messageBubbleContent: some View {
        Group {
            if messageViewModel.usesScrollView {
                ScrollView {
                    MessageView(
                        factory: factory,
                        message: message,
                        text: messageViewModel.textContent,
                        contentWidth: contentWidth,
                        isFirst: showsAllInfo,
                        scrolledId: $scrolledId
                    )
                }
            } else {
                MessageView(
                    factory: factory,
                    message: message,
                    text: messageViewModel.textContent,
                    contentWidth: contentWidth,
                    isFirst: showsAllInfo,
                    scrolledId: $scrolledId
                )
            }
        }
        .overlay(
            messageViewModel.topReactionsShown ?
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
                : nil,
            alignment: messageViewModel.isRightAligned ? .trailing : .leading
        )
        .overlay(
            messageViewModel.failureIndicatorShown ? SendFailureIndicator() : nil
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
