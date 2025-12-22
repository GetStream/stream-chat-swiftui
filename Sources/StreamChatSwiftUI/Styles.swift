//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

@MainActor
public protocol Styles {
    var composerPlacement: ComposerPlacement { get set }
    
    associatedtype ComposerInputViewModifier: ViewModifier
    func makeComposerInputViewModifier(options: ComposerInputModifierOptions) -> ComposerInputViewModifier
    
    associatedtype ComposerButtonViewModifier: ViewModifier
    func makeComposerButtonViewModifier(options: ComposerButtonModifierOptions) -> ComposerButtonViewModifier
    
    associatedtype ChannelListContentModifier: ViewModifier
    /// Returns a view modifier applied to the channel list content (including both header and footer views).
    func makeChannelListContentModifier(options: ChannelListContentModifierOptions) -> ChannelListContentModifier

    associatedtype ChannelListModifier: ViewModifier
    /// Returns a view modifier applied to the channel list.
    func makeChannelListModifier(options: ChannelListModifierOptions) -> ChannelListModifier
    
    associatedtype MessageListModifier: ViewModifier
    /// Returns a view modifier applied to the message list.
    func makeMessageListModifier(options: MessageListModifierOptions) -> MessageListModifier
    
    associatedtype MessageListContainerModifier: ViewModifier
    /// Returns a view modifier applied to the message list container.
    func makeMessageListContainerModifier(options: MessageListContainerModifierOptions) -> MessageListContainerModifier

    associatedtype MessageViewModifier: ViewModifier
    /// Returns a view modifier applied to the message view.
    /// - Parameter messageModifierInfo: the message modifier info, that will be applied to the message.
    func makeMessageViewModifier(for messageModifierInfo: MessageModifierInfo) -> MessageViewModifier

    associatedtype BouncedMessageActionsModifierType: ViewModifier
    /// Returns a view modifier applied to the bounced message actions.
    ///
    /// This modifier is only used if `Utils.messageListConfig.bouncedMessagesAlertActionsEnabled` is `true`.
    /// By default the flag is true and the bounced actions are shown as an alert instead of a context menu.
    /// - Parameter viewModel: the view model of the chat channel view.
    func makeBouncedMessageActionsModifier(viewModel: ChatChannelViewModel) -> BouncedMessageActionsModifierType

    associatedtype ComposerViewModifier: ViewModifier
    /// Creates the composer view modifier, that's applied to the whole composer view.
    func makeComposerViewModifier(options: ComposerViewModifierOptions) -> ComposerViewModifier
}

extension Styles {
    public func makeChannelListContentModifier(options: ChannelListContentModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeChannelListModifier(options: ChannelListModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeMessageListModifier(options: MessageListModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeMessageListContainerModifier(options: MessageListContainerModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeMessageViewModifier(for messageModifierInfo: MessageModifierInfo) -> some ViewModifier {
        MessageBubbleModifier(
            message: messageModifierInfo.message,
            isFirst: messageModifierInfo.isFirst,
            injectedBackgroundColor: messageModifierInfo.injectedBackgroundColor,
            cornerRadius: messageModifierInfo.cornerRadius,
            forceLeftToRight: messageModifierInfo.forceLeftToRight
        )
    }
    
    public func makeBouncedMessageActionsModifier(viewModel: ChatChannelViewModel) -> some ViewModifier {
        BouncedMessageActionsModifier(viewModel: viewModel)
    }
    
    public func makeComposerViewModifier(options: ComposerViewModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
}

public class LiquidGlassStyles: Styles {
    public var composerPlacement: ComposerPlacement = .floating
    
    public init() {}
    
    public func makeComposerInputViewModifier(options: ComposerInputModifierOptions) -> some ViewModifier {
        LiquidGlassModifier(shape: CustomRoundedShape())
    }
    
    public func makeComposerButtonViewModifier(options: ComposerButtonModifierOptions) -> some ViewModifier {
        LiquidGlassModifier(shape: .circle)
    }
}

public struct StandardInputViewModifier: ViewModifier {
    @Injected(\.colors) var colors
    
    var keyboardShown: Bool
    
    public init(keyboardShown: Bool) {
        self.keyboardShown = keyboardShown
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
                    .stroke(Color(keyboardShown ? highlightedBorder : colors.innerBorder))
            )
            .clipShape(
                RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
            )
    }
    
    private var highlightedBorder: UIColor {
        var colors = colors
        return colors.composerInputHighlightedBorder
    }
}

public class ComposerInputModifierOptions {
    public let keyboardShown: Bool
    
    public init(keyboardShown: Bool) {
        self.keyboardShown = keyboardShown
    }
}

public class ComposerButtonModifierOptions {
    public init() {}
}
