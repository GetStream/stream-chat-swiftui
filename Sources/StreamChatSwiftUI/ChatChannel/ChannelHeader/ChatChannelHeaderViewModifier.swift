//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View modifier for customizing the channel header.
public protocol ChatChannelHeaderViewModifier: ViewModifier {
    var channel: ChatChannel { get }
}

/// The default channel header.
public struct DefaultChatChannelHeader<Factory: ViewFactory>: ToolbarContent {
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.chatClient) private var chatClient

    private var onlineIndicatorShown: Bool {
        !channel.lastActiveMembers.filter { member in
            member.id != chatClient.currentUserId && member.isOnline
        }
        .isEmpty
    }

    private var factory: Factory
    public var channel: ChatChannel
    public var shouldShowTypingIndicator: Bool
    @Binding public var isActive: Bool

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        shouldShowTypingIndicator: Bool,
        isActive: Binding<Bool>
    ) {
        self.factory = factory
        self.channel = channel
        self.shouldShowTypingIndicator = shouldShowTypingIndicator
        _isActive = isActive
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ChannelTitleView(
                factory: factory,
                channel: channel,
                shouldShowTypingIndicator: shouldShowTypingIndicator
            )
            .accessibilityIdentifier("ChannelTitleView")
            .accessibilityElement(children: .contain)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            ZStack {
                Button {
                    resignFirstResponder()
                    isActive = true
                } label: {
                    factory.makeChannelAvatarView(
                        options: ChannelAvatarViewOptions(
                            channel: channel,
                            size: AvatarSize.large
                        )
                    )
                    .offset(x: 4)
                }
                .accessibilityLabel(Text(L10n.Channel.Header.Info.title))

                NavigationLink(isActive: $isActive) {
                    LazyView(ChatChannelInfoView(factory: factory, channel: channel, shownFromMessageList: true))
                } label: {
                    EmptyView()
                }
                .accessibilityHidden(true)
            }
            .accessibilityIdentifier("ChannelAvatar")
        }
    }
}

/// The default header modifier.
public struct DefaultChannelHeaderModifier<Factory: ViewFactory>: ChatChannelHeaderViewModifier {
    @State private var isActive: Bool = false

    private var factory: Factory
    public var channel: ChatChannel
    public var shouldShowTypingIndicator: Bool
    
    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        shouldShowTypingIndicator: Bool
    ) {
        self.factory = factory
        self.channel = channel
        self.shouldShowTypingIndicator = shouldShowTypingIndicator
    }

    public func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .toolbarThemed {
                    DefaultChatChannelHeader(
                        factory: factory,
                        channel: channel,
                        shouldShowTypingIndicator: shouldShowTypingIndicator,
                        isActive: $isActive
                    )
                    #if compiler(>=6.2)
                    .sharedBackgroundVisibility(.hidden)
                    #endif
                }
        } else {
            content
                .toolbarThemed {
                    DefaultChatChannelHeader(
                        factory: factory,
                        channel: channel,
                        shouldShowTypingIndicator: shouldShowTypingIndicator,
                        isActive: $isActive
                    )
                }
        }
    }
}

public struct ChannelTitleView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.chatClient) private var chatClient

    private var factory: Factory
    let channel: ChatChannel
    let shouldShowTypingIndicator: Bool

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        shouldShowTypingIndicator: Bool
    ) {
        self.factory = factory
        self.channel = channel
        self.shouldShowTypingIndicator = shouldShowTypingIndicator
    }
    
    private var currentUserId: String {
        chatClient.currentUserId ?? ""
    }

    public var body: some View {
        VStack(spacing: 2) {
            Text(name(for: channel))
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.navigationBarTitle))
                .accessibilityIdentifier("chatName")

            if shouldShowTypingIndicator {
                factory.makeSubtitleTypingIndicatorView(
                    options: SubtitleTypingIndicatorViewOptions(
                        channel: channel
                    )
                )
            } else {
                Text(channel.onlineInfoText(currentUserId: currentUserId))
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.navigationBarSubtitle))
                    .accessibilityIdentifier("chatOnlineInfo")
            }
        }
    }
    
    private func name(for channel: ChatChannel) -> String {
        utils.channelNameFormatter.format(
            channel: channel,
            forCurrentUserId: chatClient.currentUserId
        ) ?? ""
    }
}
