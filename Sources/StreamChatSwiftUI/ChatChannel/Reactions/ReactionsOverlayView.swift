//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ReactionsOverlayView<Factory: ViewFactory>: View {
    @StateObject var viewModel: ReactionsOverlayViewModel
    
    var factory: Factory
    var channel: ChatChannel
    var currentSnapshot: UIImage
    var messageDisplayInfo: MessageDisplayInfo
    var onBackgroundTap: () -> Void
    var onActionExecuted: (MessageActionInfo) -> Void
    
    private var messageActionsCount: Int
    private let padding: CGFloat = 16
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
                .blur(radius: 8)
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
            
            VStack(alignment: .leading) {
                MessageView(
                    factory: factory,
                    message: messageDisplayInfo.message,
                    contentWidth: messageDisplayInfo.contentWidth,
                    isFirst: messageDisplayInfo.isFirst,
                    scrolledId: .constant(nil)
                )
                .offset(
                    x: messageDisplayInfo.frame.origin.x
                )
                .overlay(
                    ReactionsOverlayContainer(
                        message: viewModel.message,
                        contentRect: messageDisplayInfo.frame,
                        onReactionTap: { reaction in
                            viewModel.reactionTapped(reaction)
                            onBackgroundTap()
                        }
                    )
                    .offset(
                        x: messageDisplayInfo.frame.origin.x,
                        y: -24
                    )
                )
                .frame(
                    width: messageDisplayInfo.frame.width,
                    height: messageDisplayInfo.frame.height
                )
                
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
                    x: messageActionsOriginX
                )
                .padding(.top, 16)
            }
            .offset(y: originY)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var originY: CGFloat {
        var messageActionsSize = messageItemSize * CGFloat(messageActionsCount)
        if messageActionsSize > maxMessageActionsSize {
            messageActionsSize = maxMessageActionsSize
        }
        var originY = messageDisplayInfo.frame.origin.y
        let screenHeight = UIScreen.main.bounds.size.height
        let minOrigin: CGFloat = 100
        let maxOrigin: CGFloat = screenHeight - messageDisplayInfo.frame.height - messageActionsSize - minOrigin
        if originY < minOrigin {
            originY = minOrigin
        } else if originY > maxOrigin {
            originY = maxOrigin
        }
        
        return originY
    }
    
    private var messageActionsOriginX: CGFloat {
        if messageDisplayInfo.message.isSentByCurrentUser {
            let screenWidth = UIScreen.main.bounds.size.width
            return screenWidth - messageActionsWidth - padding / 2
        } else {
            return CGSize.messageAvatarSize.width + padding
        }
    }
    
    private var messageActionsWidth: CGFloat {
        var width = messageDisplayInfo.contentWidth
        if messageDisplayInfo.message.isSentByCurrentUser {
            width -= 2 * padding
        }
        
        return width
    }
}
