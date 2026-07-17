//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Chat channel screen that renders its messages from the top using a
/// non-inverted list (see ``TopAlignedMessageListView``), together with the
/// standard composer and navigation header.
///
/// This is the counterpart to ``ChatChannelView`` for the
/// `shouldMessagesStartAtTheTop` mode; it keeps its own ``.bottomToTop`` backed
/// view model so the default inverted screen is untouched.
public struct TopAlignedChatChannelView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    @StateObject private var viewModel: TopAlignedChatChannelViewModel
    private var factory: Factory

    @State private var keyboardShown = false

    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        channelController: ChatChannelController
    ) {
        _viewModel = StateObject(
            wrappedValue: TopAlignedChatChannelViewModel(channelController: channelController)
        )
        factory = viewFactory
    }

    public var body: some View {
        ZStack {
            if let channel = viewModel.channel {
                VStack(spacing: 0) {
                    TopAlignedMessageListView(
                        factory: factory,
                        channel: channel,
                        messages: viewModel.messages,
                        messagesGroupingInfo: viewModel.messagesGroupingInfo,
                        scrolledId: $viewModel.scrolledId,
                        quotedMessage: $viewModel.quotedMessage,
                        scrollToNewestToken: viewModel.scrollToNewestToken,
                        onLoadOlder: viewModel.loadOlderIfNeeded,
                        onLongPress: { _ in }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    composerView

                    // Carries the navigation header modifier without affecting layout.
                    Color.clear
                        .frame(height: 0)
                        .modifier(
                            factory.makeChannelHeaderViewModifier(
                                options: ChannelHeaderViewModifierOptions(
                                    channel: channel,
                                    shouldShowTypingIndicator: false
                                )
                            )
                        )
                }
            } else {
                factory.makeChannelLoadingView(options: ChannelLoadingViewOptions())
            }
        }
        .navigationBarTitleDisplayMode(utils.messageListConfig.navigationBarDisplayMode)
        .onReceive(keyboardWillChangePublisher) { visible in
            keyboardShown = visible
            if visible {
                // Keep the newest message above the keyboard. No-op for short
                // conversations that already fit.
                viewModel.scrollToLastMessage()
            }
        }
        .accentColor(Color(colors.accentPrimary))
    }

    private var composerView: some View {
        factory.makeMessageComposerViewType(
            options: MessageComposerViewTypeOptions(
                channelController: viewModel.channelController,
                messageController: nil,
                quotedMessage: $viewModel.quotedMessage,
                editedMessage: $viewModel.editedMessage,
                willSendMessage: {
                    viewModel.messageSentTapped()
                }
            )
        )
    }
}
