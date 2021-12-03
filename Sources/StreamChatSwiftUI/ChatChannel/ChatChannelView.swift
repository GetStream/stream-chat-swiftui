//
// Copyright © 2021 Stream.io Inc. All rights reserved.
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
        channelController: ChatChannelController
    ) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeChannelViewModel(with: channelController)
        )
        factory = viewFactory
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            MessageListView(
                factory: factory,
                messages: viewModel.messages,
                messagesGroupingInfo: viewModel.messagesGroupingInfo,
                scrolledId: $viewModel.scrolledId,
                showScrollToLatestButton: $viewModel.showScrollToLatestButton,
                currentDateString: viewModel.currentDateString,
                isGroup: !viewModel.channel.isDirectMessageChannel,
                unreadCount: viewModel.channel.unreadCount.messages,
                listId: viewModel.listId,
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
                .if(!viewModel.reactionsShown) { view in
                    view.modifier(factory.makeChannelHeaderViewModifier(for: viewModel.channel))
                }
            
            factory.makeMessageComposerViewType(
                with: viewModel.channelController,
                onMessageSent: viewModel.scrollToLastMessage
            )
        }
        .accentColor(colors.tintColor)
        .overlay(
            viewModel.reactionsShown ?
                factory.makeReactionsOverlayView(
                    currentSnapshot: viewModel.currentSnapshot!,
                    messageDisplayInfo: messageDisplayInfo!,
                    onBackgroundTap: {
                        viewModel.reactionsShown = false
                    }
                )
                .transition(.identity)
                .edgesIgnoringSafeArea(.all)
                : nil
        )
    }
}
