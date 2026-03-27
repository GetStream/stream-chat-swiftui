//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A reactions overlay view that shows reactions, message and actions.
///
/// Layout (top to bottom):
/// - Reactions picker (emoji row with + button)
/// - Message bubble (with avatar for incoming messages)
/// - Message actions menu
///
/// The message animates from its original position in the message list
/// to a computed position that fits all content on screen.
public struct ReactionsOverlayView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    @StateObject var viewModel: ReactionsOverlayViewModel
    @StateObject var messageViewModel: MessageViewModel

    // MARK: - Animation State

    @State private var popIn = false
    @State private var willPopOut = false

    // MARK: - Layout State

    @State private var screenHeight = UIScreen.main.bounds.size.height
    @State private var orientationChanged = false
    @State private var moreReactionsShown = false
    @State private var measuredTotalContentHeight: CGFloat = 0

    private let factory: Factory
    private let channel: ChatChannel
    private let currentSnapshot: UIImage
    private let verticalInset: CGFloat
    private let messageDisplayInfo: MessageDisplayInfo
    private let onBackgroundTap: () -> Void
    private let onActionExecuted: (MessageActionInfo) -> Void

    // MARK: - Init

    public init(
        factory: Factory,
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        verticalInset: CGFloat = 40,
        onBackgroundTap: @escaping () -> Void,
        onActionExecuted: @escaping (MessageActionInfo) -> Void,
        viewModel: ReactionsOverlayViewModel? = nil,
        messageViewModel: MessageViewModel? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeReactionsOverlayViewModel(
                message: messageDisplayInfo.message
            )
        )
        _messageViewModel = StateObject(
            wrappedValue: messageViewModel ?? MessageViewModel(
                message: messageDisplayInfo.message,
                channel: channel
            )
        )
        self.channel = channel
        self.factory = factory
        self.currentSnapshot = currentSnapshot
        self.verticalInset = verticalInset
        self.messageDisplayInfo = messageDisplayInfo
        self.onBackgroundTap = onBackgroundTap
        self.onActionExecuted = onActionExecuted
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .topLeading) {
            backgroundView

            GeometryReader { reader in
                let height = reader.frame(in: .local).height
                Color.clear.preference(key: HeightPreferenceKey.self, value: height)

                VStack(alignment: isRightAligned ? .trailing : .leading, spacing: tokens.spacingXs) {
                    reactionsPickerView(reader: reader)
                    factory.makeMessageItemView(
                        options: MessageItemViewOptions(
                            channel: channel,
                            message: messageDisplayInfo.message,
                            width: messageDisplayInfo.frame.width,
                            fixedContentWidth: messageDisplayInfo.contentWidth,
                            showsAllInfo: messageDisplayInfo.isFirst,
                            shownAsPreview: true,
                            isInThread: false,
                            scrolledId: .constant(nil),
                            quotedMessage: .constant(nil),
                            onLongPress: { _ in },
                            isLast: false,
                            viewModel: messageViewModel
                        )
                    )
                    .frame(width: messageDisplayInfo.frame.width)
                    .frame(maxHeight: messageDisplayInfo.frame.height)
                    .environment(\.channelTranslationLanguage, channel.membership?.language)
                    .scaleEffect(popIn || willPopOut ? 1 : 0.95)
                    .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                    messageActionsView(reader: reader)
                }
                .frame(width: overlayContentWidth, alignment: isRightAligned ? .trailing : .leading)
                .frame(height: measuredTotalContentHeight > 0 ? min(measuredTotalContentHeight, allowedTotalContentHeight) : nil)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: OverlayContentHeightKey.self,
                            value: proxy.size.height
                        )
                    }
                )
                .offset(x: contentOffsetX(reader: reader), y: contentOffsetY)
            }
        }
        .onPreferenceChange(HeightPreferenceKey.self) { value in
            if let value, value != screenHeight {
                screenHeight = value
            }
        }
        .onPreferenceChange(OverlayContentHeightKey.self) { value in
            if value > 0 {
                measuredTotalContentHeight = value
            }
        }
        .onChange(of: measuredTotalContentHeight) { _ in
            messageViewModel.usesScrollView = usesScrollView
        }
        .onChange(of: screenHeight) { _ in
            messageViewModel.usesScrollView = usesScrollView
        }
        .edgesIgnoringSafeArea(.all)
        .background(orientationChanged ? nil : Color(colors.backgroundElevation1))
        .onAppear {
            popIn = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ReactionsOverlayView")
        .onRotate { _ in
            if isIPad {
                orientationChanged = true
            }
        }
        .sheet(isPresented: $moreReactionsShown) {
            factory.makeMoreReactionsView(options: .init(onEmojiTap: { reactionKey in
                moreReactionsShown = false
                let reaction = MessageReactionType(rawValue: reactionKey)
                withAnimation {
                    dismissReactionsOverlay {
                        viewModel.reactionTapped(reaction)
                    }
                }
            }))
            .modifier(PresentationDetentsModifier(sheetSizes: [.medium, .large]))
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        ZStack {
            if !orientationChanged {
                Image(uiImage: currentSnapshot)
                    .overlay(
                        Color(colors.backgroundCoreScrim)
                            .edgesIgnoringSafeArea(.all)
                            .opacity(popIn ? 1 : 0)
                    )
                    .blur(radius: popIn ? 4 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .offset(y: overlayOffsetY)
            } else {
                Color(colors.backgroundCoreScrim)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .transition(.opacity)
        .onTapGesture {
            dismissReactionsOverlay { /* No additional handling. */ }
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $viewModel.errorShown) {
            Alert.defaultErrorAlert
        }
    }

    // MARK: - Reactions Picker

    @ViewBuilder
    private func reactionsPickerView(reader: GeometryProxy) -> some View {
        if channel.config.reactionsEnabled && !messageDisplayInfo.message.isBounced {
            HStack(spacing: 0) {
                if isRightAligned { Spacer() }
                factory.makeReactionsContentView(
                    options: ReactionsContentViewOptions(
                        message: viewModel.message,
                        contentRect: messageDisplayInfo.frame,
                        onReactionTap: { reaction in
                            dismissReactionsOverlay {
                                viewModel.reactionTapped(reaction)
                            }
                        },
                        onMoreReactionsTap: {
                            moreReactionsShown.toggle()
                        }
                    )
                )
                .scaleEffect(popIn ? 1 : 0)
                .opacity(willPopOut ? 0 : 1)
                .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                .accessibilityElement(children: .contain)
                if !isRightAligned { Spacer() }
            }
            .padding(.leading, !isRightAligned ? messageBubbleLeadingX : 0)
            .padding(.trailing, isRightAligned ? messageHorizontalPadding : 0)
        }
    }

    // MARK: - Message Actions

    @ViewBuilder
    private func messageActionsView(reader: GeometryProxy) -> some View {
        if messageDisplayInfo.showsMessageActions {
            HStack(spacing: 0) {
                if isRightAligned { Spacer() }
                factory.makeMessageActionsView(
                    options: MessageActionsViewOptions(
                        message: messageDisplayInfo.message,
                        channel: channel,
                        onFinish: { actionInfo in
                            onActionExecuted(actionInfo)
                        },
                        onError: { _ in
                            viewModel.errorShown = true
                        }
                    )
                )
                .frame(minWidth: 250, alignment: isRightAligned ? .trailing : .leading)
                .fixedSize(horizontal: true, vertical: false)
                .opacity(willPopOut ? 0 : 1)
                .scaleEffect(popIn ? 1 : (willPopOut ? 0.4 : 0))
                .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                if !isRightAligned { Spacer() }
            }
            .padding(.leading, !isRightAligned ? messageBubbleLeadingX : 0)
            .padding(.trailing, isRightAligned ? messageHorizontalPadding : 0)
        }
    }

    // MARK: - Dismiss

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

    // MARK: - Layout Helpers

    private var isRightAligned: Bool {
        messageDisplayInfo.message.isRightAligned
    }

    private var showAvatars: Bool {
        utils.messageListConfig.messageDisplayOptions.showAvatars(for: channel, incoming: !isRightAligned)
    }

    private var messageHorizontalPadding: CGFloat {
        utils.messageListConfig.messagePaddings.horizontal
    }

    /// The leading X position where the message bubble starts (after avatar + spacing).
    /// Used to align the reactions picker and actions with the message bubble.
    private var messageBubbleLeadingX: CGFloat {
        if showAvatars {
            return messageHorizontalPadding + AvatarSize.medium + tokens.spacingXs
        }
        return messageHorizontalPadding
    }

    private var overlayContentWidth: CGFloat {
        messageDisplayInfo.frame.width
    }

    // MARK: - Animation

    private var popInAnimation: Animation {
        .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2)
    }

    // MARK: - Origin Y

    private var usesScrollView: Bool {
        guard measuredTotalContentHeight > 0 else { return false }
        return measuredTotalContentHeight >= allowedTotalContentHeight
    }
    
    private var allowedTotalContentHeight: CGFloat { screenHeight - topContentSpacing - bottomContentSpacing }
    
    private var topContentSpacing: CGFloat { topSafeArea + verticalInset + spacing }
    private var bottomContentSpacing: CGFloat { bottomSafeArea + verticalInset }
    
    private var contentOffsetY: CGFloat {
        let originalMessageMatchingOffsetY = messageDisplayInfo.frame.origin.y - spacing - topReactionsWithPickerHeight
        if !popIn {
            return originalMessageMatchingOffsetY
        }
        let maxOrigin = originalMessageMatchingOffsetY + measuredTotalContentHeight
        let bottomClippingAvoidingOffset = min(screenHeight - bottomContentSpacing - maxOrigin, 0)
        return max(topContentSpacing, originalMessageMatchingOffsetY + bottomClippingAvoidingOffset)
    }

    private func contentOffsetX(reader: GeometryProxy) -> CGFloat {
        let overlayFrame = reader.frame(in: .global)
        let originalMessageOriginX = messageDisplayInfo.frame.minX - overlayFrame.minX
        let maxAllowedOffset = max(0, reader.size.width - overlayContentWidth)
        return min(max(0, originalMessageOriginX), maxAllowedOffset)
    }

    private var topReactionsWithPickerHeight: CGFloat {
        guard channel.config.reactionsEnabled, !messageDisplayInfo.message.isBounced else { return 0 }
        return 48 + tokens.spacingXs
    }

    private var overlayOffsetY: CGFloat {
        if isIPad && UITabBar.appearance().isHidden == false {
            return 20
        }
        return spacing > 0 ? screenHeight - currentSnapshot.size.height : 0
    }

    private var spacing: CGFloat {
        let divider: CGFloat = isIPad ? 2 : 1
        let spacing = (UIScreen.main.bounds.height - screenHeight) / divider
        return spacing > 0 ? spacing : 0
    }
}

// MARK: - Preference Keys

private struct OverlayContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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

struct PresentationDetentsModifier: ViewModifier {
    var sheetSizes: [SheetSize]
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents(Set(sheetSizes.map(\.toPresentationDetent)))
        } else {
            content
        }
    }
}

enum SheetSize {
    case custom(CGFloat)
    case medium
    case large
    
    @available(iOS 16.0, *)
    var toPresentationDetent: PresentationDetent {
        switch self {
        case .custom(let height):
            return .height(height)
        case .medium:
            return .medium
        case .large:
            return .large
        }
    }
}
