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
    @State private var orientation = UIDevice.current.orientation
    
    private var factory: Factory
    
    private let orientationChanged = NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
            
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
                        .if(multipleOrientationsSupported) { view in
                            view.id(orientation.rawValue)
                        }
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
                            }, onActionExecuted: { actionInfo in
                                viewModel.messageActionExecuted(actionInfo)
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
        .onReceive(orientationChanged) { _ in
            if multipleOrientationsSupported {
                self.orientation = UIDevice.current.orientation
            }
        }
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
        .padding(.bottom, keyboardShown || !tabBarAvailable ? 0 : bottomPadding)
        .ignoresSafeArea(.container, edges: tabBarAvailable ? .bottom : [])
    }
    
    private var bottomPadding: CGFloat {
        let bottomPadding = topVC()?.view.safeAreaInsets.bottom ?? 0
        return bottomPadding
    }
    
    private var multipleOrientationsSupported: Bool {
        let orientationsKey = "UISupportedInterfaceOrientations"
        let orientations = Bundle.main.infoDictionary?[orientationsKey] as? [String] ?? []
        return orientations.count > 1
    }
}
