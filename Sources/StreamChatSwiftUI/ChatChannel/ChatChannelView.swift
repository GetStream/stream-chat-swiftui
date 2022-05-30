//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat channel.
public struct ChatChannelView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    
    @StateObject private var viewModel: ChatChannelViewModel
    
    @State private var messageDisplayInfo: MessageDisplayInfo?
    @State private var keyboardShown = false
    @State private var tabBarAvailable: Bool = false
    
    private var factory: Factory
            
    public init(
        viewFactory: Factory,
        viewModel: ChatChannelViewModel? = nil,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        scrollToMessage: ChatMessage? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeChannelViewModel(
                with: channelController,
                messageController: messageController,
                scrollToMessage: scrollToMessage
            )
        )
        factory = viewFactory
    }
    
    public var body: some View {
        ZStack {
            if let channel = viewModel.channel {
                VStack(spacing: 0) {
                    if !viewModel.messages.isEmpty {
                        MessageListView(
                            factory: factory,
                            channel: channel,
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
                                messageDisplayInfo = displayInfo
                                withAnimation {
                                    viewModel.showReactionOverlay()
                                }
                            }
                        )
                        .overlay(
                            viewModel.currentDateString != nil ?
                                factory.makeDateIndicatorView(dateString: viewModel.currentDateString!)
                                : nil
                        )
                    } else {
                        factory.makeEmptyMessagesView(for: channel, colors: colors)
                    }
                    
                    Divider()
                        .navigationBarBackButtonHidden(viewModel.reactionsShown)
                        .if(viewModel.reactionsShown, transform: { view in
                            view.navigationBarHidden(true)
                        })
                        .if(viewModel.channelHeaderType == .regular) { view in
                            view.modifier(factory.makeChannelHeaderViewModifier(for: channel))
                        }
                        .if(viewModel.channelHeaderType == .typingIndicator) { view in
                            view.modifier(factory.makeChannelHeaderViewModifier(for: channel))
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
                    .opacity((
                        utils.messageListConfig.messagePopoverEnabled && messageDisplayInfo != nil && !viewModel
                            .reactionsShown
                    ) ? 0 : 1)
                }
                .accentColor(colors.tintColor)
                .overlay(
                    viewModel.reactionsShown ?
                        factory.makeReactionsOverlayView(
                            channel: channel,
                            currentSnapshot: viewModel.currentSnapshot!,
                            messageDisplayInfo: messageDisplayInfo!,
                            onBackgroundTap: {
                                viewModel.reactionsShown = false
                                if messageDisplayInfo?.keyboardWasShown == true {
                                    becomeFirstResponder()
                                }
                                messageDisplayInfo = nil
                            }, onActionExecuted: { actionInfo in
                                viewModel.messageActionExecuted(actionInfo)
                                messageDisplayInfo = nil
                            }
                        )
                        .transition(.identity)
                        .edgesIgnoringSafeArea(.all)
                        : nil
                )
            } else {
                LoadingView()
            }
        }
        .onReceive(keyboardWillChangePublisher, perform: { visible in
            keyboardShown = visible
        })
        .onAppear {
            viewModel.onViewAppear()
            if utils.messageListConfig.becomesFirstResponderOnOpen {
                keyboardShown = true
            }
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
        .padding(.bottom, keyboardShown || !tabBarAvailable || generatingSnapshot ? 0 : bottomPadding)
        .ignoresSafeArea(.container, edges: tabBarAvailable ? .bottom : [])
    }
    
    private var generatingSnapshot: Bool {
        tabBarAvailable && messageDisplayInfo != nil && !viewModel.reactionsShown
    }
    
    private var bottomPadding: CGFloat {
        let bottomPadding = topVC()?.view.safeAreaInsets.bottom ?? 0
        return bottomPadding
    }
}
