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
    @State private var measuredActionsContentWidth: CGFloat = 0

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
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: height)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissReactionsOverlay { /* No additional handling. */ }
                    }

                let content = VStack(alignment: isRightAligned ? .trailing : .leading, spacing: tokens.spacingXs) {
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
                    // Let the preview take its natural height (including the timestamp/avatar)
                    // rather than capping it to the captured frame. Capping would either clip
                    // that content or, without clipping, let it bleed over the reactions picker
                    // above; any genuine overflow is instead absorbed by the overlay's scroll.
                    .fixedSize(horizontal: false, vertical: true)
                    .scaleEffect(popIn || willPopOut ? 1 : 0.95)
                    .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                    .onTapGesture {
                        dismissReactionsOverlay { /* No additional handling. */ }
                    }
                    messageActionsView(reader: reader)
                }
                .frame(width: overlayContentWidth(reader: reader), alignment: isRightAligned ? .trailing : .leading)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: OverlayContentHeightKey.self,
                            value: proxy.size.height
                        )
                    }
                )

                // When the whole content (reactions + message + actions) is taller than the
                // screen — which can happen at large Dynamic Type sizes — it becomes scrollable
                // instead of being squeezed into an overlapping, unreadable stack. The scroll
                // view spans the full height so the content can scroll under the status bar and
                // home indicator, matching the UIKit message actions popup.
                if contentExceedsScreen {
                    ScrollView(showsIndicators: false) {
                        content
                            .padding(.top, topContentSpacing)
                            .padding(.bottom, bottomContentSpacing)
                    }
                    .frame(width: overlayContentWidth(reader: reader), height: screenHeight)
                    .offset(x: contentOffsetX(reader: reader))
                } else {
                    content
                        .offset(x: contentOffsetX(reader: reader), y: contentOffsetY)
                }
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
        .onPreferenceChange(ActionsContentWidthKey.self) { value in
            if value > 0 {
                measuredActionsContentWidth = value
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(orientationChanged ? nil : Color(colors.backgroundCoreElevation1))
        .onAppear {
            popIn = true
            // Once the chat behind the overlay is hidden, tell VoiceOver the screen
            // changed so it moves focus into the overlay (the reactions picker)
            // instead of staying on a now-hidden message.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ReactionsOverlayView")
        .accessibilityAction(.escape) {
            dismissReactionsOverlay { /* No additional handling. */ }
        }
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
        // The blurred snapshot and scrim are purely decorative; keep them out of
        // the accessibility tree so VoiceOver focuses the overlay's content.
        .accessibilityHidden(true)
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
            let available = availableActionsWidth(reader: reader)
            // At large Dynamic Type sizes the actions menu's natural width can exceed the
            // screen. Only then do we constrain it to the available width (letting the row
            // titles truncate), so the common case keeps its natural, unchanged sizing.
            let needsConstrain = measuredActionsContentWidth > 0 && measuredActionsContentWidth > available
            HStack(spacing: 0) {
                if isRightAligned { Spacer() }
                factory.makeMessageActionsView(options: actionsViewOptions)
                    .frame(minWidth: 250, alignment: isRightAligned ? .trailing : .leading)
                    .frame(maxWidth: needsConstrain ? available : nil)
                    .fixedSize(horizontal: !needsConstrain, vertical: false)
                    // Natural width is measured off an always-fixed-size hidden copy so the
                    // measurement stays stable even while the visible menu is being constrained.
                    .background(actionsNaturalWidthReader)
                    .opacity(willPopOut ? 0 : 1)
                    .scaleEffect(popIn ? 1 : (willPopOut ? 0.4 : 0))
                    .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
                if !isRightAligned { Spacer() }
            }
            .padding(.leading, !isRightAligned ? messageBubbleLeadingX : 0)
            .padding(.trailing, isRightAligned ? messageHorizontalPadding : 0)
        }
    }

    private var actionsViewOptions: MessageActionsViewOptions {
        MessageActionsViewOptions(
            message: messageDisplayInfo.message,
            channel: channel,
            onFinish: { actionInfo in
                onActionExecuted(actionInfo)
            },
            onError: { _ in
                viewModel.errorShown = true
            }
        )
    }

    /// A hidden, always-natural-width copy of the actions menu used solely to measure its
    /// intrinsic width. Kept out of the accessibility tree and non-interactive.
    private var actionsNaturalWidthReader: some View {
        factory.makeMessageActionsView(options: actionsViewOptions)
            .frame(minWidth: 250)
            .fixedSize(horizontal: true, vertical: false)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: ActionsContentWidthKey.self, value: proxy.size.width)
                }
            )
            .hidden()
            .allowsHitTesting(false)
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
            // The chat is visible again now that the overlay is gone; let VoiceOver
            // re-scan so focus returns to the message list instead of being orphaned.
            UIAccessibility.post(notification: .screenChanged, argument: nil)
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

    /// The width available for the actions menu after accounting for the horizontal insets
    /// applied to it, so it never has to draw past the edges of the screen.
    private func availableActionsWidth(reader: GeometryProxy) -> CGFloat {
        let leadingInset = isRightAligned ? messageHorizontalPadding : messageBubbleLeadingX
        return max(0, reader.size.width - leadingInset - messageHorizontalPadding)
    }

    /// Width of the content column (reactions, message, actions).
    ///
    /// Normally this matches the captured message width, which keeps the layout identical to
    /// before. Only when the actions menu's natural width would overflow the screen does the
    /// column widen so that the horizontal offset clamp keeps the (now constrained) menu on
    /// screen instead of letting it spill past the edges.
    private func overlayContentWidth(reader: GeometryProxy) -> CGFloat {
        let available = availableActionsWidth(reader: reader)
        guard measuredActionsContentWidth > available, available > 0 else {
            return messageDisplayInfo.frame.width
        }
        let leadingInset = isRightAligned ? messageHorizontalPadding : messageBubbleLeadingX
        return min(max(messageDisplayInfo.frame.width, leadingInset + available), reader.size.width)
    }

    // MARK: - Animation

    private var popInAnimation: Animation {
        .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2)
    }

    // MARK: - Origin Y

    private var contentExceedsScreen: Bool {
        measuredTotalContentHeight > 0 && measuredTotalContentHeight > allowedTotalContentHeight
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
        let maxAllowedOffset = max(0, reader.size.width - overlayContentWidth(reader: reader))
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

private struct ActionsContentWidthKey: PreferenceKey {
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
