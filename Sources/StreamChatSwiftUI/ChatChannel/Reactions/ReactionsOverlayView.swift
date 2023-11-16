//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ReactionsOverlayView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    
    @StateObject var viewModel: ReactionsOverlayViewModel

    @State private var popIn = false
    @State private var willPopOut = false
    @State private var screenHeight = UIScreen.main.bounds.size.height
    @State private var screenWidth: CGFloat?
    @State private var initialWidth: CGFloat?
    @State private var orientationChanged = false
    @State private var initialOrigin: CGFloat?

    var factory: Factory
    var channel: ChatChannel
    var currentSnapshot: UIImage
    var bottomOffset: CGFloat
    var messageDisplayInfo: MessageDisplayInfo
    var onBackgroundTap: () -> Void
    var onActionExecuted: (MessageActionInfo) -> Void

    private var messageActionsCount: Int
    private let paddingValue: CGFloat = 16
    private let messageItemSize: CGFloat = 40
    private var maxMessageActionsSize: CGFloat {
        screenHeight / 3
    }

    public init(
        factory: Factory,
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        bottomOffset: CGFloat = 0,
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
        self.bottomOffset = bottomOffset
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
            ZStack {
                if !orientationChanged {
                    factory.makeReactionsBackgroundView(
                        currentSnapshot: currentSnapshot,
                        popInAnimationInProgress: !popIn
                    )
                    .offset(y: spacing > 0 ? screenHeight - currentSnapshot.size.height : 0)
                } else {
                    Color.gray.opacity(0.4)
                }
            }
            .transition(.opacity)
            .onTapGesture {
                dismissReactionsOverlay() { /* No additional handling. */ }
            }
            .edgesIgnoringSafeArea(.all)
            .alert(isPresented: $viewModel.errorShown) {
                Alert.defaultErrorAlert
            }

            if !messageDisplayInfo.message.isRightAligned &&
                utils.messageListConfig.messageDisplayOptions.showAvatars(for: channel) {
                factory.makeMessageAvatarView(
                    for: utils.messageCachingUtils.authorInfo(from: messageDisplayInfo.message)
                )
                .offset(
                    x: paddingValue / 2,
                    y: originY + messageContainerHeight - paddingValue + 2
                )
                .opacity(willPopOut ? 0 : 1)
            }

            GeometryReader { reader in
                let frame = reader.frame(in: .local)
                let height = frame.height
                let width = frame.width
                Color.clear.preference(key: HeightPreferenceKey.self, value: height)
                Color.clear.preference(key: WidthPreferenceKey.self, value: width)
                
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
                    .scaleEffect(popIn || willPopOut ? 1 : 0.95)
                    .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                    .offset(
                        x: messageOriginX(proxy: reader)
                    )
                    .overlay(
                        channel.config.reactionsEnabled ?
                            factory.makeReactionsContentView(
                                message: viewModel.message,
                                contentRect: messageDisplayInfo.frame,
                                onReactionTap: { reaction in
                                    dismissReactionsOverlay {
                                        viewModel.reactionTapped(reaction)
                                    }
                                }
                            )
                            .scaleEffect(popIn ? 1 : 0)
                            .opacity(willPopOut ? 0 : 1)
                            .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                            .offset(
                                x: messageOriginX(proxy: reader),
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
                            x: messageActionsOffsetX(reader: reader),
                            y: popIn ? 0 : -messageActionsSize / 2
                        )
                        .padding(.top, paddingValue)
                        .opacity(willPopOut ? 0 : 1)
                        .scaleEffect(popIn ? 1 : (willPopOut ? 0.4 : 0))
                        .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                    } else if messageDisplayInfo.showsBottomContainer {
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
                        .opacity(willPopOut ? 0 : 1)
                        .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                    }
                }
                .offset(y: !popIn ? (messageDisplayInfo.frame.origin.y - spacing) : originY)
                .onAppear {
                    self.initialOrigin = messageDisplayInfo.frame.origin.x - diffWidth(proxy: reader)
                }
            }
        }
        .onPreferenceChange(HeightPreferenceKey.self) { value in
            if let value = value, value != screenHeight {
                self.screenHeight = value
            }
        }
        .onPreferenceChange(WidthPreferenceKey.self) { value in
            if initialWidth == nil {
                initialWidth = value
            }
            self.screenWidth = value
        }
        .edgesIgnoringSafeArea(.all)
        .background(orientationChanged ? nil : Color(colors.background))
        .onAppear {
            popIn = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ReactionsOverlayView")
        .onRotate { _ in
            if isIPad {
                self.orientationChanged = true
            }
        }
    }

    private func dismissReactionsOverlay(completion: @escaping () -> Void) {
        withAnimation {
            willPopOut = true
            popIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onBackgroundTap()
            completion()
        }
    }

    private func messageActionsOffsetX(reader: GeometryProxy) -> CGFloat {
        let originX = messageActionsOriginX(availableWidth: reader.size.width)
        if popIn {
            return originX
        } else if willPopOut {
            return messageOriginX(proxy: reader)
        } else {
            return messageDisplayInfo.message.isRightAligned ? messageActionsWidth : 0
        }
    }
        
    private func messageOriginX(proxy: GeometryProxy) -> CGFloat {
        let origin = messageDisplayInfo.frame.origin.x - diffWidth(proxy: proxy)
        if let initialWidth, let initialOrigin, let screenWidth, abs(initialWidth - screenWidth) > 5 {
            let diff = initialWidth - initialOrigin
            let newOrigin = screenWidth - diff
            return newOrigin
        }
        return initialOrigin ?? origin
    }

    private var messageContainerHeight: CGFloat {
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
        let minOrigin: CGFloat = 100
        let maxOrigin: CGFloat = screenHeight - messageContainerHeight - bottomPopupOffset - minOrigin - bottomOffset
        if originY < minOrigin {
            originY = minOrigin
        } else if originY > maxOrigin {
            originY = maxOrigin
        }
        
        return originY - spacing
    }
    
    private var spacing: CGFloat {
        let divider: CGFloat = isIPad ? 2 : 1
        let spacing = (UIScreen.main.bounds.height - screenHeight) / divider
        return spacing > 0 ? spacing : 0
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
        if messageDisplayInfo.message.isRightAligned {
            return availableWidth - messageActionsWidth - paddingValue / 2
        } else {
            return CGSize.messageAvatarSize.width + paddingValue
        }
    }

    private func userReactionsOriginX(availableWidth: CGFloat) -> CGFloat {
        if messageDisplayInfo.message.isRightAligned {
            return availableWidth - maxUserReactionsWidth(availableWidth: availableWidth) - paddingValue / 2
        } else {
            return paddingValue
        }
    }

    private var messageActionsWidth: CGFloat {
        var width = messageDisplayInfo.contentWidth + 2 * paddingValue
        if messageDisplayInfo.message.isRightAligned {
            width -= 2 * paddingValue
        }

        return width
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        modifier(DeviceRotationViewModifier(action: action))
    }
}
