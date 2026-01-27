//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
    @State private var floatingComposerHeight: CGFloat
    
    private var factory: Factory

    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        viewModel: ChatChannelViewModel? = nil,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        scrollToMessage: ChatMessage? = nil,
        composerPlacement: ComposerPlacement = .floating
    ) {
        _floatingComposerHeight = State(initialValue: Self.defaultFloatingComposerHeight())
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
                            bottomInset: composerPlacement == .floating ? floatingComposerHeight : 0,
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
                        .edgesIgnoringSafeArea(.bottom)
                        .environment(\.highlightedMessageId, viewModel.highlightedMessageId)
                        .dismissKeyboardOnTap(enabled: true) {
                            hideComposerCommandsAndAttachmentsPicker()
                        }
                        .overlay(
                            viewModel.currentDateString != nil ?
                                factory.makeDateIndicatorView(options: DateIndicatorViewOptions(dateString: viewModel.currentDateString!))
                                : nil
                        )
                    } else {
                        ZStack {
                            factory.makeEmptyMessagesView(options: EmptyMessagesViewOptions(channel: channel))
                                .dismissKeyboardOnTap(enabled: keyboardShown) {
                                    hideComposerCommandsAndAttachmentsPicker()
                                }
                            if viewModel.shouldShowTypingIndicator {
                                factory.makeTypingIndicatorBottomView(
                                    options: TypingIndicatorBottomViewOptions(
                                        channel: channel,
                                        currentUserId: chatClient.currentUserId
                                    )
                                )
                            }
                        }
                    }

                    Divider()
                        .opacity(0)
                        .navigationBarBackButtonHidden(viewModel.reactionsShown)
                        .if(viewModel.reactionsShown, transform: { view in
                            view.modifier(factory.makeChannelBarsVisibilityViewModifier(options: ChannelBarsVisibilityViewModifierOptions(shouldShow: false)))
                        })
                        .if(!viewModel.reactionsShown, transform: { view in
                            view.modifier(factory.makeChannelBarsVisibilityViewModifier(options: ChannelBarsVisibilityViewModifierOptions(shouldShow: true)))
                        })
                        .if(viewModel.channelHeaderType == .regular) { view in
                            view.modifier(factory.makeChannelHeaderViewModifier(options: ChannelHeaderViewModifierOptions(channel: channel)))
                        }
                        .if(viewModel.channelHeaderType == .typingIndicator) { view in
                            view.modifier(factory.makeChannelHeaderViewModifier(options: ChannelHeaderViewModifierOptions(channel: channel)))
                        }
                        .if(viewModel.channelHeaderType == .messageThread) { view in
                            view.modifier(factory.makeMessageThreadHeaderViewModifier(options: MessageThreadHeaderViewModifierOptions()))
                        }
                        .animation(nil)

                    if composerPlacement == .docked {
                        composerView
                            .padding(.top, 8)
                            .overlay(
                                Rectangle()
                                    .frame(width: nil, height: 1, alignment: .top)
                                    .foregroundColor(Color(colors.borderCoreDefault)), alignment: .top
                            )

                            .opacity((
                                utils.messageListConfig.messagePopoverEnabled && messageDisplayInfo != nil && !viewModel
                                    .reactionsShown && viewModel.channel?.isFrozen == false
                            ) ? 0 : 1)
                    }

                    NavigationLink(
                        isActive: $viewModel.threadMessageShown
                    ) {
                        if let message = viewModel.threadMessage {
                            let threadDestination = factory.makeMessageThreadDestination(options: MessageThreadDestinationOptions())
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
                            options: ReactionsOverlayViewOptions(
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
                        )
                        .transition(.identity)
                        .edgesIgnoringSafeArea(.all)
                        : nil
                )
                .modifier(FloatingComposerContainer(
                    composerPlacement: composerPlacement,
                    composer: {
                        composerView
                            .opacity(viewModel.reactionsShown ? 0 : 1)
                    }
                ))
            } else {
                factory.makeChannelLoadingView(options: ChannelLoadingViewOptions())
            }
        }
        .onPreferenceChange(FloatingComposerHeightPreferenceKey.self) { value in
            guard composerPlacement == .floating, value > 0 else { return }
            let defaultHeight = Self.defaultFloatingComposerHeight()
            let newHeight = max(value, defaultHeight)
            floatingComposerHeight = newHeight
        }
        .navigationBarTitleDisplayMode(utils.messageListConfig.navigationBarDisplayMode)
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
            Color(factory.styles.composerPlacement == .docked ? colors.composerBg : .clear)
                .background(
                    TabBarAccessor { _ in
                        tabBarAvailable = utils.messageListConfig.handleTabBarVisibility
                    }
                )
                .ignoresSafeArea(.all)
                .allowsHitTesting(false)
        )
        .padding(.bottom, keyboardShown || !tabBarAvailable || generatingSnapshot ? 0 : bottomPadding)
        .ignoresSafeArea(.container, edges: tabBarAvailable ? .bottom : [])
        .alertBanner(isPresented: $viewModel.showAlertBanner)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ChatChannelView")
        .modifier(factory.styles.makeBouncedMessageActionsModifier(viewModel: viewModel))
        .accentColor(Color(colors.accentPrimary))
    }
    
    private var composerView: some View {
        factory.makeMessageComposerViewType(
            options: MessageComposerViewTypeOptions(
                channelController: viewModel.channelController,
                messageController: viewModel.messageController,
                quotedMessage: $viewModel.quotedMessage,
                editedMessage: $viewModel.editedMessage,
                onMessageSent: {
                    viewModel.messageSentTapped()
                }
            )
        )
    }
    
    private var composerPlacement: ComposerPlacement {
        factory.styles.composerPlacement
    }

    private var generatingSnapshot: Bool {
        if #available(iOS 26, *) {
            false
        } else {
            tabBarAvailable && messageDisplayInfo != nil && !viewModel.reactionsShown
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

public enum ComposerPlacement {
    case docked
    case floating
}

private extension ChatChannelView {
    static func defaultFloatingComposerHeight() -> CGFloat {
        let utils = InjectedValues[\.utils]
        let baseHeight = utils.composerConfig.inputViewMinHeight
        let spacing: CGFloat = 60
        return baseHeight + spacing
    }
}

private struct FloatingComposerContainer<Composer: View>: ViewModifier {
    let composerPlacement: ComposerPlacement
    let composer: () -> Composer

    func body(content: Content) -> some View {
        if composerPlacement == .docked {
            content
        } else {
            if #available(iOS 15.0, *) {
                content
                    .overlay(alignment: .bottom) {
                        composer()
                    }
            } else {
                content
                    .overlay(
                        VStack {
                            Spacer()
                            composer()
                        }
                    )
            }
        }
    }
}
