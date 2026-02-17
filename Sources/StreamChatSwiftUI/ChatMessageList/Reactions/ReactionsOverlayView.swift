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
    @State private var measuredReactionsPickerHeight: CGFloat = 0
    @State private var measuredTotalContentHeight: CGFloat = 0

    // MARK: - Properties

    var factory: Factory
    var channel: ChatChannel
    var currentSnapshot: UIImage
    var bottomOffset: CGFloat
    var messageDisplayInfo: MessageDisplayInfo
    var onBackgroundTap: () -> Void
    var onActionExecuted: (MessageActionInfo) -> Void

    private let paddingValue: CGFloat = 16
    private let minOriginY: CGFloat

    // MARK: - Init

    public init(
        factory: Factory,
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        minOriginY: CGFloat = 100,
        bottomOffset: CGFloat = 0,
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
        self.minOriginY = minOriginY
        self.bottomOffset = bottomOffset
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
                    messageAndTimestampView(reader: reader)
                    messageActionsView(reader: reader)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: OverlayContentHeightKey.self,
                            value: proxy.size.height
                        )
                    }
                )
                .offset(y: contentOffsetY)
            }
        }
        .onPreferenceChange(HeightPreferenceKey.self) { value in
            if let value, value != screenHeight {
                screenHeight = value
            }
        }
        .onPreferenceChange(OverlayReactionsPickerHeightKey.self) { value in
            if value > 0 {
                measuredReactionsPickerHeight = value
            }
        }
        .onPreferenceChange(OverlayContentHeightKey.self) { value in
            if value > 0 {
                measuredTotalContentHeight = value
            }
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
                            .opacity(popIn ? 1 : 0)
                    )
                    .blur(radius: popIn ? 4 : 0)
                    .offset(y: overlayOffsetY)
            } else {
                Color(colors.backgroundCoreScrim)
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
            .padding(.trailing, isRightAligned ? paddingValue / 2 : 0)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: OverlayReactionsPickerHeightKey.self,
                        value: proxy.size.height
                    )
                }
            )
        }
    }

    // MARK: - Message + Timestamp (with avatar aligned to timestamp)

    @ViewBuilder
    private func messageAndTimestampView(reader: GeometryProxy) -> some View {
        HStack(alignment: .bottom, spacing: tokens.spacingXs) {
            if isRightAligned { Spacer() }

            if !isRightAligned && showAvatars {
                factory.makeUserAvatarView(
                    options: .init(
                        user: messageDisplayInfo.message.author,
                        size: AvatarSize.medium,
                        showsIndicator: false
                    )
                )
                .opacity(willPopOut ? 0 : 1)
            }

            VStack(alignment: isRightAligned ? .trailing : .leading, spacing: tokens.spacingXxs) {
                Group {
                    if messageDisplayInfo.frame.height > messageContainerHeight {
                        ScrollView {
                            messageView
                        }
                    } else {
                        messageView
                    }
                }
                .overlay(
                    topReactionsShown
                        ? factory.makeMessageReactionView(
                            options: MessageReactionViewOptions(
                                message: messageDisplayInfo.message,
                                onTapGesture: {},
                                onLongPressGesture: {}
                            )
                        )
                        : nil,
                    alignment: isRightAligned ? .trailing : .leading
                )
                .environment(\.channelTranslationLanguage, channel.membership?.language)
                .scaleEffect(popIn || willPopOut ? 1 : 0.95)
                .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                .frame(
                    width: messageDisplayInfo.frame.width,
                    height: messageContainerHeight
                )
                .padding(
                    .top,
                    topReactionsShown ? tokens.spacingLg : 0
                )
                .accessibilityIdentifier("ReactionsMessageView")

                if bottomReactionsShown {
                    factory.makeBottomReactionsView(
                        options: ReactionsBottomViewOptions(
                            message: messageDisplayInfo.message,
                            showsAllInfo: messageDisplayInfo.isFirst,
                            onTap: {},
                            onLongPress: {}
                        )
                    )
                }

                if messageViewModel.messageDateShown {
                    factory.makeMessageDateView(
                        options: MessageDateViewOptions(
                            message: messageDisplayInfo.message,
                            textColor: colors.textOnAccent.toColor
                        )
                    )
                    .opacity(willPopOut ? 0 : 1)
                    .padding(.bottom, tokens.spacingXxs)
                }
            }

            if !isRightAligned { Spacer() }
        }
        .padding(.leading, !isRightAligned ? paddingValue / 2 : 0)
        .padding(.trailing, isRightAligned ? paddingValue / 2 : 0)
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
                .frame(width: messageActionsWidth)
                .opacity(willPopOut ? 0 : 1)
                .scaleEffect(popIn ? 1 : (willPopOut ? 0.4 : 0))
                .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                if !isRightAligned { Spacer() }
            }
            .padding(.leading, !isRightAligned ? messageBubbleLeadingX : 0)
            .padding(.trailing, isRightAligned ? paddingValue / 2 : 0)
        }
    }

    // MARK: - Message View

    private var messageView: some View {
        MessageView(
            factory: factory,
            message: messageDisplayInfo.message,
            contentWidth: messageDisplayInfo.contentWidth,
            isFirst: messageDisplayInfo.isFirst,
            scrolledId: .constant(nil)
        )
        .environment(\.messageViewModel, messageViewModel)
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
        utils.messageListConfig.messageDisplayOptions.showAvatars(for: channel)
    }

    // MARK: - Message Reactions (badges on message)

    private var topReactionsShown: Bool {
        if utils.messageListConfig.messageDisplayOptions.reactionsPlacement == .bottom {
            return false
        }
        return messageReactionsShown
    }

    private var bottomReactionsShown: Bool {
        if utils.messageListConfig.messageDisplayOptions.reactionsPlacement == .top {
            return false
        }
        return messageReactionsShown
    }

    private var messageReactionsShown: Bool {
        let message = messageDisplayInfo.message
        return !message.reactionScores.isEmpty
            && !message.isDeleted
            && channel.config.reactionsEnabled
    }

    /// The leading X position where the message bubble starts (after avatar + spacing).
    /// Used to align the reactions picker and actions with the message bubble.
    private var messageBubbleLeadingX: CGFloat {
        if showAvatars {
            return paddingValue / 2 + AvatarSize.medium + tokens.spacingXs
        }
        return paddingValue / 2
    }

    private var messageContainerHeight: CGFloat {
        let maxAllowed = screenHeight / 2 - topSafeArea
        let containerHeight = messageDisplayInfo.frame.height
        return containerHeight > maxAllowed ? maxAllowed : containerHeight
    }

    private var messageActionsWidth: CGFloat {
        var width = messageDisplayInfo.contentWidth + 2 * paddingValue
        if isRightAligned {
            width -= 2 * paddingValue
        }
        return width
    }

    // MARK: - Animation

    private var popInAnimation: Animation {
        .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2)
    }

    // MARK: - Origin Y

    /// The Y offset for the entire content VStack.
    /// Animates from the message's original position to a computed position
    /// that ensures all content (reactions + message + actions) fits on screen.
    ///
    /// The VStack contains reactions picker above the message, so we subtract
    /// the reactions area height so the **message bubble** (not the VStack top)
    /// aligns with its original position during pop-in/pop-out animations.
    private var contentOffsetY: CGFloat {
        if !popIn {
            return messageDisplayInfo.frame.origin.y - spacing - reactionsAreaOffset
        }
        return originY
    }

    private var originY: CGFloat {
        var originY = messageDisplayInfo.frame.origin.y - reactionsAreaOffset
        let maxOrigin = screenHeight - measuredTotalContentHeight - minOriginY - bottomOffset
        if originY < minOriginY {
            originY = minOriginY
        } else if originY > maxOrigin {
            originY = maxOrigin
        }
        return max(0, originY - spacing)
    }

    private var reactionsAreaOffset: CGFloat {
        guard channel.config.reactionsEnabled, !messageDisplayInfo.message.isBounced else { return 0 }
        return measuredReactionsPickerHeight + tokens.spacingXs
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

private struct OverlayReactionsPickerHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

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
    case medium
    case large
    
    @available(iOS 16.0, *)
    var toPresentationDetent: PresentationDetent {
        switch self {
        case .medium:
            return .medium
        case .large:
            return .large
        }
    }
}
