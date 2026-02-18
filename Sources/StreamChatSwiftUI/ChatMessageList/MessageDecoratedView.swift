//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A view that renders a fully decorated message: avatar, bubble, reactions,
/// thread replies, translated-text footer and delivery-status metadata.
struct MessageDecoratedView<Factory: ViewFactory>: View {
    @StateObject var messageViewModel: MessageViewModel

    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils
    @Injected(\.tokens) private var tokens

    var factory: Factory
    let channel: ChatChannel
    let message: ChatMessage
    var contentWidth: CGFloat
    var isFirst: Bool
    var isInThread: Bool
    var isLast: Bool
    var isPinned: Bool
    @Binding var scrolledId: String?

    var onReactionTap: @MainActor () -> Void = {}
    var onReactionLongPress: @MainActor () -> Void = {}

    /// Creates a decorated message view.
    /// - Parameters:
    ///   - factory: The view factory for creating sub-views.
    ///   - channel: The channel the message belongs to.
    ///   - message: The message to render.
    ///   - contentWidth: Maximum width available for the message content.
    ///   - isFirst: Whether this is the first (bottom-most) message in a group, showing full metadata.
    ///   - isInThread: Whether the message is displayed inside a thread (hides thread reply indicators).
    ///   - isLast: Whether this is the last (top-most) message in the list.
    ///   - isPinned: Whether the message is pinned (shows pin details).
    ///   - scrolledId: Binding used to scroll to a specific message.
    ///   - viewModel: An existing view model to reuse; creates a new one if `nil`.
    ///   - onReactionTap: Called when a reaction is tapped (defaults to no-op).
    ///   - onReactionLongPress: Called when a reaction is long-pressed (defaults to no-op).
    init(
        factory: Factory,
        channel: ChatChannel,
        message: ChatMessage,
        contentWidth: CGFloat,
        isFirst: Bool,
        isInThread: Bool,
        isLast: Bool = false,
        isPinned: Bool,
        scrolledId: Binding<String?>,
        viewModel: MessageViewModel? = nil,
        onReactionTap: @escaping @MainActor () -> Void = {},
        onReactionLongPress: @escaping @MainActor () -> Void = {}
    ) {
        self.factory = factory
        self.channel = channel
        self.message = message
        self.contentWidth = contentWidth
        self.isFirst = isFirst
        self.isInThread = isInThread
        self.isLast = isLast
        self.isPinned = isPinned
        _scrolledId = scrolledId
        self.onReactionTap = onReactionTap
        self.onReactionLongPress = onReactionLongPress
        _messageViewModel = .init(
            wrappedValue: viewModel ?? MessageViewModel(
                message: message,
                channel: channel
            )
        )
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: tokens.spacingXs) {
            if !messageViewModel.isRightAligned {
                avatarView
            }

            VStack(
                alignment: messageViewModel.isRightAligned ? .trailing : .leading,
                spacing: tokens.spacingXxs
            ) {
                if isPinned {
                    MessagePinDetailsView(
                        message: message,
                        reactionsShown: topReactionsShown
                    )
                }

                MessageView(
                    factory: factory,
                    message: message,
                    contentWidth: contentWidth,
                    isFirst: isFirst,
                    scrolledId: $scrolledId
                )
                .overlay(
                    topReactionsShown ?
                        factory.makeMessageReactionView(
                            options: MessageReactionViewOptions(
                                message: message,
                                onTapGesture: onReactionTap,
                                onLongPressGesture: onReactionLongPress
                            )
                        )
                        .offset(x: messageViewModel.isRightAligned ? -tokens.spacingXs : tokens.spacingXs)
                        : nil,
                    alignment: messageViewModel.isRightAligned ? .trailing : .leading
                )
                .overlay(
                    messageViewModel.failureIndicatorShown ? SendFailureIndicator() : nil
                )
                .frame(maxWidth: contentWidth, alignment: messageViewModel.isRightAligned ? .trailing : .leading)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("MessageView")

                if !isInThread {
                    threadRepliesView
                }

                if bottomReactionsShown {
                    factory.makeBottomReactionsView(
                        options: ReactionsBottomViewOptions(
                            message: message,
                            showsAllInfo: isFirst,
                            onTap: onReactionTap,
                            onLongPress: onReactionLongPress
                        )
                    )
                }

                if messageViewModel.translatedText != nil {
                    factory.makeMessageTranslationFooterView(
                        options: MessageTranslationFooterViewOptions(
                            messageViewModel: messageViewModel
                        )
                    )
                }

                if isFirst && !message.isDeleted {
                    deliveryStatusView
                }
            }

            if messageViewModel.isRightAligned {
                avatarView
            }
        }
        .frame(maxWidth: .infinity, alignment: messageViewModel.isRightAligned ? .trailing : .leading)
        .padding(
            .top,
            topReactionsShown && !messageViewModel.isPinned ? messageListConfig.messageDisplayOptions
                .reactionsTopPadding(message) : 0
        )
        .padding(.horizontal, messageListConfig.messagePaddings.horizontal)
        .padding(.bottom, isFirst || messageViewModel.isPinned ? paddingValue : groupMessageInterItemSpacing)
        .padding(.top, isLast ? paddingValue : 0)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageDecoratedView")
        // This is needed for the LinkDetectionTextView to work properly.
        // TODO: This should be refactored on v5 so the TextView does not depend directly on the view model.
        .environment(\.messageViewModel, messageViewModel)
        .onChange(of: message) { message in messageViewModel.message = message }
        .onChange(of: channel) { channel in messageViewModel.channel = channel }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var avatarView: some View {
        factory.makeUserAvatarView(
            options: UserAvatarViewOptions(
                user: message.author,
                size: AvatarSize.medium,
                showsIndicator: false
            )
        )
        .opacity(isLast || isFirst ? 1 : 0)
    }

    @ViewBuilder
    private var threadRepliesView: some View {
        if message.replyCount > 0 {
            factory.makeMessageRepliesView(
                options: MessageRepliesViewOptions(
                    channel: channel,
                    message: message,
                    replyCount: message.replyCount
                )
            )
            .accessibilityElement(children: .contain)
            .accessibility(identifier: "MessageRepliesView")
        } else if message.showReplyInChannel,
                  let parentId = message.parentMessageId,
                  let controller = utils.channelControllerFactory.currentChannelController,
                  let parentMessage = controller.dataStore.message(id: parentId) {
            factory.makeMessageRepliesShownInChannelView(
                options: MessageRepliesShownInChannelViewOptions(
                    channel: channel,
                    message: message,
                    parentMessage: parentMessage,
                    replyCount: parentMessage.replyCount
                )
            )
            .accessibilityElement(children: .contain)
            .accessibility(identifier: "MessageRepliesView")
        } else if message.showReplyInChannel, let parentId = message.parentMessageId {
            LazyMessageRepliesView(
                factory: factory,
                channel: channel,
                message: message,
                parentMessageController: chatClient.messageController(
                    cid: channel.cid,
                    messageId: parentId
                )
            )
            .accessibilityElement(children: .contain)
            .accessibility(identifier: "MessageRepliesView")
        }
    }

    @ViewBuilder
    private var deliveryStatusView: some View {
        if message.isSentByCurrentUser && channel.config.readEventsEnabled {
            HStack(spacing: tokens.spacingXxs) {
                factory.makeMessageReadIndicatorView(
                    options: MessageReadIndicatorViewOptions(
                        channel: channel,
                        message: message
                    )
                )

                if messageViewModel.messageDateShown {
                    factory.makeMessageDateView(
                        options: MessageDateViewOptions(message: message)
                    )
                }
            }
            .padding(.bottom, tokens.spacingXxs)
        } else if messageViewModel.authorAndDateShown {
            factory.makeMessageAuthorAndDateView(
                options: MessageAuthorAndDateViewOptions(message: message)
            )
            .padding(.bottom, tokens.spacingXxs)
        } else if messageViewModel.messageDateShown {
            factory.makeMessageDateView(
                options: MessageDateViewOptions(message: message)
            )
            .padding(.bottom, tokens.spacingXxs)
        }
    }

    // MARK: - Computed Properties

    private var topReactionsShown: Bool {
        if messageListConfig.messageDisplayOptions.reactionsPlacement == .bottom {
            return false
        }
        return reactionsShown
    }

    private var bottomReactionsShown: Bool {
        if messageListConfig.messageDisplayOptions.reactionsPlacement == .top {
            return false
        }
        return reactionsShown
    }

    private var reactionsShown: Bool {
        !message.reactionScores.isEmpty
            && !message.isDeleted
            && channel.config.reactionsEnabled
    }

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
