//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat channel.
public struct ChatChannelView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    @StateObject private var viewModel: ChatChannelViewModel

    @Environment(\.presentationMode) var presentationMode

    @State private var messageDisplayInfo: MessageDisplayInfo?
    @State private var keyboardShown = false
    @State private var tabBarAvailable: Bool = false

    private var factory: Factory

    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
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
                            shouldShowTypingIndicator: viewModel.shouldShowTypingIndicator,
                            scrollPosition: $viewModel.scrollPosition,
                            loadingNextMessages: viewModel.loadingNextMessages,
                            firstUnreadMessageId: $viewModel.firstUnreadMessageId,
                            onMessageAppear: viewModel.handleMessageAppear(index:scrollDirection:),
                            onScrollToBottom: viewModel.scrollToLastMessage,
                            onLongPress: { displayInfo in
                                let isBouncedAlertEnabled = utils.messageListConfig.bouncedMessagesAlertActionsEnabled
                                if isBouncedAlertEnabled && displayInfo.message.isBounced {
                                    viewModel.showBouncedActionsView(for: displayInfo.message)
                                } else {
                                    messageDisplayInfo = displayInfo
                                    withAnimation {
                                        viewModel.showReactionOverlay(for: AnyView(self))
                                    }
                                }
                            },
                            onJumpToMessage: viewModel.jumpToMessage(messageId:)
                        )
                        .environment(\.highlightedMessageId, viewModel.highlightedMessageId)
                        .dismissKeyboardOnTap(enabled: true) {
                            hideComposerCommandsAndAttachmentsPicker()
                        }
                        .overlay(
                            viewModel.currentDateString != nil ?
                                factory.makeDateIndicatorView(dateString: viewModel.currentDateString!)
                                : nil
                        )
                    } else {
                        ZStack {
                            factory.makeEmptyMessagesView(for: channel, colors: colors)
                                .dismissKeyboardOnTap(enabled: keyboardShown) {
                                    hideComposerCommandsAndAttachmentsPicker()
                                }
                            if viewModel.shouldShowTypingIndicator {
                                factory.makeTypingIndicatorBottomView(
                                    channel: channel,
                                    currentUserId: chatClient.currentUserId
                                )
                            }
                        }
                    }

                    Divider()
                        .navigationBarBackButtonHidden(viewModel.reactionsShown)
                        .if(viewModel.reactionsShown, transform: { view in
                            view.modifier(factory.makeChannelBarsVisibilityViewModifier(shouldShow: false))
                        })
                        .if(!viewModel.reactionsShown, transform: { view in
                            view.modifier(factory.makeChannelBarsVisibilityViewModifier(shouldShow: true))
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
                        .animation(nil)

                    factory.makeMessageComposerViewType(
                        with: viewModel.channelController,
                        messageController: viewModel.messageController,
                        quotedMessage: $viewModel.quotedMessage,
                        editedMessage: $viewModel.editedMessage,
                        onMessageSent: {
                            viewModel.messageSentTapped()
                        }
                    )
                    .opacity((
                        utils.messageListConfig.messagePopoverEnabled && messageDisplayInfo != nil && !viewModel
                            .reactionsShown && viewModel.channel?.isFrozen == false
                    ) ? 0 : 1)

                    NavigationLink(
                        isActive: $viewModel.threadMessageShown
                    ) {
                        if let message = viewModel.threadMessage {
                            let threadDestination = factory.makeMessageThreadDestination()
                            threadDestination(channel, message)
                        } else {
                            EmptyView()
                        }
                    } label: {
                        EmptyView()
                    }
                    .opacity(0) // Fixes showing accessibility button shape
                }
                .overlay(
                    viewModel.currentSnapshot != nil && messageDisplayInfo != nil && viewModel.reactionsShown ?
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
                factory.makeChannelLoadingView()
            }
        }
        .navigationBarTitleDisplayMode(factory.navigationBarDisplayMode())
        .onReceive(keyboardWillChangePublisher, perform: { visible in
            keyboardShown = visible
        })
        .onReceive(NotificationCenter.default.publisher(
            for: NSNotification.Name(dismissChannel)
        ), perform: { _ in
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            viewModel.onViewAppear()
            if utils.messageListConfig.becomesFirstResponderOnOpen {
                keyboardShown = true
            }
        }
        .onDisappear {
            viewModel.onViewDissappear()
            viewModel.reactionsShown = false
            messageDisplayInfo = nil
        }
        .background(
            Color(colors.background).background(
                TabBarAccessor { _ in
                    self.tabBarAvailable = utils.messageListConfig.handleTabBarVisibility
                }
            )
            .ignoresSafeArea(.keyboard)
            .allowsHitTesting(false)
        )
        .padding(.bottom, keyboardShown || !tabBarAvailable || generatingSnapshot ? 0 : bottomPadding)
        .ignoresSafeArea(.container, edges: tabBarAvailable ? .bottom : [])
        .alertBanner(isPresented: $viewModel.showAlertBanner)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ChatChannelView")
        .modifier(factory.makeBouncedMessageActionsModifier(viewModel: viewModel))
        .accentColor(colors.tintColor)
    }

    private var generatingSnapshot: Bool {
        if #available(iOS 26, *) {
            return false
        } else {
            return tabBarAvailable && messageDisplayInfo != nil && !viewModel.reactionsShown
        }
    }

    private var bottomPadding: CGFloat {
        let bottomPadding = topVC()?.view.safeAreaInsets.bottom ?? 0
        return bottomPadding
    }

    private func hideComposerCommandsAndAttachmentsPicker() {
        NotificationCenter.default.post(
            name: .attachmentPickerHiddenNotification, object: nil
        )
        NotificationCenter.default.post(
            name: .commandsOverlayHiddenNotification, object: nil
        )
    }
}
