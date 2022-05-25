//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ReactionsOverlayView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils
    
    @StateObject var viewModel: ReactionsOverlayViewModel
    
    @State private var popIn = false
    
    var factory: Factory
    var channel: ChatChannel
    var currentSnapshot: UIImage
    var messageDisplayInfo: MessageDisplayInfo
    var onBackgroundTap: () -> Void
    var onActionExecuted: (MessageActionInfo) -> Void
    
    private var messageActionsCount: Int
    private let paddingValue: CGFloat = 16
    private let messageItemSize: CGFloat = 40
    private let maxMessageActionsSize: CGFloat = UIScreen.main.bounds.size.height / 3
    
    public init(
        factory: Factory,
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        onBackgroundTap: @escaping () -> Void,
        onActionExecuted: @escaping (MessageActionInfo) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeReactionsOverlayViewModel(
                message: messageDisplayInfo.message
            )
        )
        self.channel = channel
        self.factory = factory
        self.currentSnapshot = currentSnapshot
        self.messageDisplayInfo = messageDisplayInfo
        self.onBackgroundTap = onBackgroundTap
        self.onActionExecuted = onActionExecuted
        messageActionsCount = factory.supportedMessageActions(
            for: messageDisplayInfo.message,
            channel: channel,
            onFinish: { _ in /* No handling needed. */ },
            onError: { _ in /* No handling needed. */ }
        ).count
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            Image(uiImage: currentSnapshot)
                .overlay(Color.black.opacity(0.1))
                .blur(radius: 4)
                .transition(.opacity)
                .onTapGesture {
                    withAnimation {
                        onBackgroundTap()
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .alert(isPresented: $viewModel.errorShown) {
                    Alert.defaultErrorAlert
                }
            
            if !messageDisplayInfo.message.isSentByCurrentUser &&
                utils.messageListConfig.messageDisplayOptions.showAvatars {
                factory.makeMessageAvatarView(
                    for: utils.messageCachingUtils.authorInfo(from: messageDisplayInfo.message)
                )
                .offset(
                    x: paddingValue / 2,
                    y: originY + messageContainerHeight - paddingValue + 2
                )
            }
            
            GeometryReader { reader in
                VStack(alignment: .leading) {
                    Group {
                        if messageDisplayInfo.frame.height > messageContainerHeight {
                            ScrollView {
                                MessageView(
                                    factory: factory,
                                    message: messageDisplayInfo.message,
                                    contentWidth: messageDisplayInfo.contentWidth,
                                    isFirst: messageDisplayInfo.isFirst,
                                    scrolledId: .constant(nil)
                                )
                            }
                        } else {
                            MessageView(
                                factory: factory,
                                message: messageDisplayInfo.message,
                                contentWidth: messageDisplayInfo.contentWidth,
                                isFirst: messageDisplayInfo.isFirst,
                                scrolledId: .constant(nil)
                            )
                        }
                    }
                    .scaleEffect(popIn ? 1 : 0.95)
                    .animation(popInAnimation, value: popIn)
                    .offset(
                        x: messageDisplayInfo.frame.origin.x - diffWidth(proxy: reader)
                    )
                    .overlay(
                        channel.config.reactionsEnabled ?
                            ReactionsOverlayContainer(
                                message: viewModel.message,
                                contentRect: messageDisplayInfo.frame,
                                onReactionTap: { reaction in
                                    viewModel.reactionTapped(reaction)
                                    onBackgroundTap()
                                }
                            )
                            .scaleEffect(popIn ? 1 : 0)
                            .animation(popInAnimation, value: popIn)
                            .offset(
                                x: messageDisplayInfo.frame.origin.x - diffWidth(proxy: reader),
                                y: popIn ? -24 : -messageContainerHeight / 2
                            )
                            .accessibilityElement(children: .contain)
                            : nil
                    )
                    .frame(
                        width: messageDisplayInfo.frame.width,
                        height: messageContainerHeight
                    )
                    .accessibilityIdentifier("ReactionsMessageView")
                    
                    if messageDisplayInfo.showsMessageActions {
                        factory.makeMessageActionsView(
                            for: messageDisplayInfo.message,
                            channel: channel,
                            onFinish: { actionInfo in
                                onActionExecuted(actionInfo)
                            },
                            onError: { _ in
                                viewModel.errorShown = true
                            }
                        )
                        .frame(width: messageActionsWidth)
                        .offset(
                            x: popIn ? messageActionsOriginX(availableWidth: reader.size.width) :
                                (messageDisplayInfo.message.isSentByCurrentUser ? messageActionsWidth : 0),
                            y: popIn ? 0 : -messageActionsSize / 2
                        )
                        .padding(.top, paddingValue)
                        .scaleEffect(popIn ? 1 : 0)
                        .animation(popInAnimation, value: popIn)
                    } else {
                        factory.makeReactionsUsersView(
                            message: viewModel.message,
                            maxHeight: userReactionsHeight
                        )
                        .frame(maxWidth: maxUserReactionsWidth(availableWidth: reader.size.width))
                        .offset(
                            x: userReactionsOriginX(availableWidth: reader.size.width)
                        )
                        .padding(.top, messageDisplayInfo.message.isSentByCurrentUser ? paddingValue : 2 * paddingValue)
                        .padding(.trailing, paddingValue)
                        .scaleEffect(popIn ? 1 : 0)
                        .animation(popInAnimation, value: popIn)
                    }
                }
                .offset(y: originY)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            popIn = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ReactionsOverlayView")
    }
    
    private var messageContainerHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.size.height
        let maxAllowed = screenHeight / 2
        let containerHeight = messageDisplayInfo.frame.height
        return containerHeight > maxAllowed ? maxAllowed : containerHeight
    }
    
    private var popInAnimation: Animation {
        .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2)
    }
    
    private var userReactionsHeight: CGFloat {
        let reactionsCount = viewModel.message.latestReactions.count
        if reactionsCount > 4 {
            return 280
        } else {
            return 140
        }
    }
    
    private var originY: CGFloat {
        let bottomPopupOffset =
            messageDisplayInfo.showsMessageActions ? messageActionsSize : userReactionsPopupHeight
        var originY = messageDisplayInfo.frame.origin.y
        let screenHeight = UIScreen.main.bounds.size.height
        let minOrigin: CGFloat = 100
        let maxOrigin: CGFloat = screenHeight - messageContainerHeight - bottomPopupOffset - minOrigin
        if originY < minOrigin {
            originY = minOrigin
        } else if originY > maxOrigin {
            originY = maxOrigin
        }
                
        return originY
    }
    
    private var messageActionsSize: CGFloat {
        var messageActionsSize = messageItemSize * CGFloat(messageActionsCount)
        if messageActionsSize > maxMessageActionsSize {
            messageActionsSize = maxMessageActionsSize
        }
        return messageActionsSize
    }
    
    private var userReactionsPopupHeight: CGFloat {
        userReactionsHeight + 3 * paddingValue
    }
    
    private func diffWidth(proxy: GeometryProxy) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return proxy.frame(in: .global).minX
        } else {
            return 0
        }
    }
    
    private func maxUserReactionsWidth(availableWidth: CGFloat) -> CGFloat {
        availableWidth - 2 * paddingValue
    }
    
    private func messageActionsOriginX(availableWidth: CGFloat) -> CGFloat {
        if messageDisplayInfo.message.isSentByCurrentUser {
            return availableWidth - messageActionsWidth - paddingValue / 2
        } else {
            return CGSize.messageAvatarSize.width + paddingValue
        }
    }
    
    private func userReactionsOriginX(availableWidth: CGFloat) -> CGFloat {
        if messageDisplayInfo.message.isSentByCurrentUser {
            return availableWidth - maxUserReactionsWidth(availableWidth: availableWidth) - paddingValue / 2
        } else {
            return paddingValue
        }
    }
    
    private var messageActionsWidth: CGFloat {
        var width = messageDisplayInfo.contentWidth + 2 * paddingValue
        if messageDisplayInfo.message.isSentByCurrentUser {
            width -= 2 * paddingValue
        }
        
        return width
    }
}
