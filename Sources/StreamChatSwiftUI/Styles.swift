//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

@MainActor
public protocol Styles {
    var composerPlacement: ComposerPlacement { get set }
    
    associatedtype ComposerInputViewModifier: ViewModifier
    func makeComposerInputViewModifier(options: ComposerInputModifierOptions) -> ComposerInputViewModifier
    
    associatedtype ComposerButtonViewModifier: ViewModifier
    func makeComposerButtonViewModifier(options: ComposerButtonModifierOptions) -> ComposerButtonViewModifier
    
    associatedtype ScrollToBottomButtonViewModifier: ViewModifier
    func makeScrollToBottomButtonModifier(options: ScrollToBottomButtonModifierOptions) -> ScrollToBottomButtonViewModifier
    
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

    associatedtype SuggestionsContainerModifier: ViewModifier
    /// Creates the suggestions container modifier applied to the suggestions overlay.
    func makeSuggestionsContainerModifier(options: SuggestionsContainerModifierOptions) -> SuggestionsContainerModifier

    associatedtype ToolbarConfirmActionViewModifier: ViewModifier
    /// Returns a view modifier applied to toolbar confirm action buttons.
    func makeToolbarConfirmActionModifier(options: ToolbarConfirmActionModifierOptions) -> ToolbarConfirmActionViewModifier

    associatedtype SearchableModifierType: ViewModifier
    /// Returns a view modifier that adds search functionality to a view.
    ///
    /// On iOS 17+, this uses the native `.searchable` API integrated in the navigation bar.
    /// On older versions, this falls back to a custom inline ``SearchBar``.
    func makeSearchableModifier(options: SearchableModifierOptions) -> SearchableModifierType
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

    public func makeScrollToBottomButtonModifier(options: ScrollToBottomButtonModifierOptions) -> some ViewModifier {
        RegularScrollToBottomButtonModifier()
    }
    
    public func makeToolbarConfirmActionModifier(options: ToolbarConfirmActionModifierOptions) -> some ViewModifier {
        DefaultToolbarConfirmActionModifier()
    }

    public func makeSearchableModifier(options: SearchableModifierOptions) -> some ViewModifier {
        DefaultSearchableModifier(searchText: options.searchText, prompt: options.prompt)
    }
}

public class LiquidGlassStyles: Styles {
    @Injected(\.tokens) var tokens

    public var composerPlacement: ComposerPlacement = .floating
    
    public init() {}
    
    public func makeComposerInputViewModifier(options: ComposerInputModifierOptions) -> some ViewModifier {
        LiquidGlassModifier(
            shape: .roundedRect(tokens.radius3xl),
            isInteractive: true
        )
    }
    
    public func makeComposerButtonViewModifier(options: ComposerButtonModifierOptions) -> some ViewModifier {
        LiquidGlassModifier(shape: .circle, isInteractive: true)
    }
    
    public func makeScrollToBottomButtonModifier(options: ScrollToBottomButtonModifierOptions) -> some ViewModifier {
        LiquidGlassScrollToBottomButtonModifier()
    }
    
    public func makeSuggestionsContainerModifier(options: SuggestionsContainerModifierOptions) -> some ViewModifier {
        SuggestionsLiquidGlassContainerModifier()
    }
}

public class RegularStyles: Styles {
    public var composerPlacement: ComposerPlacement = .docked
    
    public init() {}
    
    public func makeComposerInputViewModifier(options: ComposerInputModifierOptions) -> some ViewModifier {
        RegularInputViewModifier()
    }
    
    public func makeComposerButtonViewModifier(options: ComposerButtonModifierOptions) -> some ViewModifier {
        RegularButtonViewModifier()
    }
    
    public func makeScrollToBottomButtonModifier(options: ScrollToBottomButtonModifierOptions) -> some ViewModifier {
        RegularScrollToBottomButtonModifier()
    }
    
    public func makeComposerViewModifier(options: ComposerViewModifierOptions) -> some ViewModifier {
        ComposerBackgroundRegularViewModifier()
    }
    
    public func makeSuggestionsContainerModifier(options: SuggestionsContainerModifierOptions) -> some ViewModifier {
        SuggestionsRegularContainerModifier()
    }
}

public struct RegularInputViewModifier: ViewModifier {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

    public init() {}

    public func body(content: Content) -> some View {
        content
            .background(Color(colors.backgroundCoreElevation1))
            .modifier(BorderModifier(shape: .roundedRect(cornerRadius)))
    }

    private var cornerRadius: CGFloat {
        tokens.radius3xl
    }
}

public struct RegularButtonViewModifier: ViewModifier {
    @Injected(\.colors) var colors
    
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .background(Color(colors.backgroundCoreElevation1))
            .modifier(BorderModifier(shape: .circle))
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

public class ScrollToBottomButtonModifierOptions {
    public init() {}
}

public class ToolbarConfirmActionModifierOptions {
    public init() {}
}

public struct ComposerBackgroundRegularViewModifier: ViewModifier {
    @Injected(\.colors) var colors

    public init() {}

    public func body(content: Content) -> some View {
        content
            .background(Color(colors.backgroundCoreElevation1))
    }
}

public class SuggestionsContainerModifierOptions {
    public init() {}
}

public struct SuggestionsRegularContainerModifier: ViewModifier {
    @Injected(\.colors) var colors

    public init() {}

    public func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Divider()
            content
        }
        .background(Color(colors.backgroundCoreElevation1))
    }
}

public struct SuggestionsLiquidGlassContainerModifier: ViewModifier {
    @Injected(\.tokens) var tokens

    public init() {}

    public func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: tokens.radius3xl))
            .modifier(
                LiquidGlassModifier(shape: .roundedRect(tokens.radius3xl))
            )
            .padding(.horizontal, tokens.spacingMd)
    }
}

public struct RegularScrollToBottomButtonModifier: ViewModifier {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

    public init() {}

    public func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(Color(colors.backgroundCoreElevation1))
                    .shadow(
                        color: Color(tokens.lightElevation3.color),
                        radius: tokens.lightElevation3.blur / 2,
                        x: tokens.lightElevation3.x,
                        y: tokens.lightElevation3.y
                    )
            )
    }
}

/// Styles a toolbar confirm action button using the native platform appearance.
///
/// On iOS 26+, applies a glass button style with the accent tint.
/// On earlier versions, falls back to a solid primary ``StreamButtonStyle``.
public struct DefaultToolbarConfirmActionModifier: ViewModifier {
    @Injected(\.colors) private var colors

    public init() {}

    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .buttonStyle(.borderedProminent)
                .tint(Color(colors.accentPrimary))
        } else {
            solidStyle(content: content)
        }
    }

    private func solidStyle(content: Content) -> some View {
        content.buttonStyle(
            StreamButtonStyle(
                role: .primary,
                style: .solid,
                size: .medium,
                isIconOnly: true
            )
        )
    }
}

public struct LiquidGlassScrollToBottomButtonModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .modifier(LiquidGlassModifier(shape: .circle, isInteractive: true))
            .offset(y: 12)
    }
}

// MARK: - Searchable

/// Options for creating the searchable view modifier.
public final class SearchableModifierOptions {
    public let searchText: Binding<String>
    public let prompt: String

    public init(
        searchText: Binding<String>,
        prompt: String? = nil
    ) {
        self.searchText = searchText
        self.prompt = prompt ?? L10n.Message.Search.title
    }
}

/// A view modifier that adds search functionality using the native `.searchable` API
/// on iOS 17+ and falls back to an inline ``SearchBar`` on older versions.
public struct DefaultSearchableModifier: ViewModifier {
    @Binding var searchText: String
    let prompt: String

    public init(searchText: Binding<String>, prompt: String) {
        _searchText = searchText
        self.prompt = prompt
    }

    public func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: Text(prompt)
                )
        } else {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                content
            }
        }
    }
}

struct BorderModifier<BackgroundShape: Shape>: ViewModifier {
    @Injected(\.colors) var colors

    var shape: BackgroundShape

    func body(content: Content) -> some View {
        content
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(Color(colors.buttonSecondaryBorder), lineWidth: 1)
            )
    }
}
