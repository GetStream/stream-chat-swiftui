//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ReactionsOverlayView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils
    
    @StateObject var viewModel: ReactionsOverlayViewModel
    
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
            onFinish: { _ in },
            onError: { _ in }
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
            
            if !messageDisplayInfo.message.isSentByCurrentUser {
                factory.makeMessageAvatarView(
                    for: utils.messageCachingUtils.authorInfo(from: messageDisplayInfo.message)
                )
                .offset(
                    x: paddingValue / 2,
                    y: originY + messageDisplayInfo.frame.height - paddingValue + 2
                )
            }
            
            GeometryReader { reader in
                VStack(alignment: .leading) {
                    MessageView(
                        factory: factory,
                        message: messageDisplayInfo.message,
                        contentWidth: messageDisplayInfo.contentWidth,
                        isFirst: messageDisplayInfo.isFirst,
                        scrolledId: .constant(nil)
                    )
                    .offset(
                        x: messageDisplayInfo.frame.origin.x - diffWidth
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
                            .offset(
                                x: messageDisplayInfo.frame.origin.x - diffWidth,
                                y: -24
                            )
                            : nil
                    )
                    .frame(
                        width: messageDisplayInfo.frame.width,
                        height: messageDisplayInfo.frame.height
                    )
                    
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
                            x: messageActionsOriginX(availableWidth: reader.size.width)
                        )
                        .padding(.top, paddingValue)
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
                    }
                }
                .offset(y: originY)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var userReactionsHeight: CGFloat {
        let reactionsCount = viewModel.message.latestReactions.count
        if reactionsCount > 4 {
            return 280
        } else {
            return 140
        }
    }
    
    private var diffWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let screenWidth = UIScreen.main.bounds.size.width
            let viewWidth = topVC()?.view.frame.width ?? 0
            return screenWidth - viewWidth
        } else {
            return 0
        }
    }
    
    private var originY: CGFloat {
        let bottomPopupOffset =
            messageDisplayInfo.showsMessageActions ? messageActionsSize : userReactionsPopupHeight
        var originY = messageDisplayInfo.frame.origin.y
        let screenHeight = UIScreen.main.bounds.size.height
        let minOrigin: CGFloat = 100
        let maxOrigin: CGFloat = screenHeight - messageDisplayInfo.frame.height - bottomPopupOffset - minOrigin
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
