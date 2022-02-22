//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat channel.
public struct ChatChannelView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    
    @StateObject private var viewModel: ChatChannelViewModel
    
    @State private var messageDisplayInfo: MessageDisplayInfo?
    @State private var keyboardShown = false
    @State private var tabBarAvailable: Bool = false
    
    private var factory: Factory
            
    public init(
        viewFactory: Factory,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        scrollToMessage: ChatMessage? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeChannelViewModel(
                with: channelController,
                messageController: messageController,
                scrollToMessage: scrollToMessage
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
            .overlay(
                viewModel.currentDateString != nil ?
                    factory.makeDateIndicatorView(dateString: viewModel.currentDateString!)
                    : nil
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
        .onReceive(keyboardWillChangePublisher, perform: { visible in
            keyboardShown = visible
        })
        .onAppear {
            viewModel.onViewAppear()
        }
        .onDisappear {
            viewModel.onViewDissappear()
        }
        .background(
            isIphone ?
                Color.clear.background(
                    TabBarAccessor { _ in
                        self.tabBarAvailable = true
                    }
                )
                .allowsHitTesting(false)
                : nil
        )
        .padding(.bottom, keyboardShown || !tabBarAvailable ? 0 : bottomPadding)
        .ignoresSafeArea(.container, edges: tabBarAvailable ? .bottom : [])
    }
    
    private var bottomPadding: CGFloat {
        let bottomPadding = topVC()?.view.safeAreaInsets.bottom ?? 0
        return bottomPadding
    }
}
