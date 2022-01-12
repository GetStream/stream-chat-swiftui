//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat channel.
public struct ChatChannelView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    
    @StateObject private var viewModel: ChatChannelViewModel
    
    @State private var messageDisplayInfo: MessageDisplayInfo?
    
    private var factory: Factory
            
    public init(
        viewFactory: Factory,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeChannelViewModel(
                with: channelController,
                messageController: messageController
            )
        )
        factory = viewFactory
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            MessageListView(
                factory: factory,
                channel: viewModel.channel,
                messages: viewModel.messages,
                messagesGroupingInfo: viewModel.messagesGroupingInfo,
                scrolledId: $viewModel.scrolledId,
                showScrollToLatestButton: $viewModel.showScrollToLatestButton,
                quotedMessage: $viewModel.quotedMessage,
                currentDateString: viewModel.currentDateString,
                isGroup: !viewModel.channel.isDirectMessageChannel,
                unreadCount: viewModel.channel.unreadCount.messages,
                listId: viewModel.listId,
                isMessageThread: viewModel.isMessageThread,
                onMessageAppear: viewModel.handleMessageAppear(index:),
                onScrollToBottom: viewModel.scrollToLastMessage,
                onLongPress: { displayInfo in
                    withAnimation {
                        messageDisplayInfo = displayInfo
                        viewModel.showReactionOverlay()
                    }
                }
            )
            
            Divider()
                .navigationBarBackButtonHidden(viewModel.reactionsShown)
                .if(viewModel.reactionsShown, transform: { view in
                    view.navigationBarHidden(true)
                })
                .if(viewModel.channelHeaderType == .regular) { view in
                    view.modifier(factory.makeChannelHeaderViewModifier(for: viewModel.channel))
                }
                .if(viewModel.channelHeaderType == .typingIndicator) { view in
                    view.modifier(factory.makeChannelHeaderViewModifier(for: viewModel.channel))
                }
                .if(viewModel.channelHeaderType == .messageThread) { view in
                    view.modifier(factory.makeMessageThreadHeaderViewModifier())
                }
            
            factory.makeMessageComposerViewType(
                with: viewModel.channelController,
                messageController: viewModel.messageController,
                quotedMessage: $viewModel.quotedMessage,
                editedMessage: $viewModel.editedMessage,
                onMessageSent: viewModel.scrollToLastMessage
            )
        }
        .accentColor(colors.tintColor)
        .overlay(
            viewModel.reactionsShown ?
                factory.makeReactionsOverlayView(
                    channel: viewModel.channel,
                    currentSnapshot: viewModel.currentSnapshot!,
                    messageDisplayInfo: messageDisplayInfo!,
                    onBackgroundTap: {
                        viewModel.reactionsShown = false
                    }, onActionExecuted: { actionInfo in
                        viewModel.messageActionExecuted(actionInfo)
                    }
                )
                .transition(.identity)
                .edgesIgnoringSafeArea(.all)
                : nil
        )
        .onAppear {
            viewModel.onViewAppear()
        }
        .onDisappear {
            viewModel.onViewDissappear()
        }
    }
}
