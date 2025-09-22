//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying pinned messages in the chat info screen.
public struct PinnedMessagesView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    @StateObject private var viewModel: PinnedMessagesViewModel
    
    let factory: Factory
    private let channel: ChatChannel

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        channelController: ChatChannelController? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: PinnedMessagesViewModel(
                channel: channel,
                channelController: channelController
            )
        )
        self.channel = channel
        self.factory = factory
    }

    public var body: some View {
        ZStack {
            if !viewModel.pinnedMessages.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.pinnedMessages) { message in
                            ZStack {
                                PinnedMessageView(factory: factory, message: message, channel: viewModel.channel)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.selectedMessage = message
                                    }
                                NavigationLink(
                                    tag: message,
                                    selection: $viewModel.selectedMessage
                                ) {
                                    LazyView(
                                        makeMessageDestination(message: message)
                                            .modifier(HideTabBarModifier(
                                                handleTabBarVisibility: utils.messageListConfig.handleTabBarVisibility
                                            ))
                                    )
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0) // Fixes showing accessibility button shape
                            }
                            Divider()
                        }
                    }
                }
            } else {
                NoContentView(
                    image: images.noContent,
                    title: L10n.ChatInfo.PinnedMessages.emptyTitle,
                    description: L10n.ChatInfo.PinnedMessages.emptyDesc,
                    shouldRotateImage: true
                )
            }
        }
        .toolbarThemed {
            ToolbarItem(placement: .principal) {
                Text(L10n.ChatInfo.PinnedMessages.title)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.navigationBarTitle))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func makeMessageDestination(message: ChatMessage) -> ChatChannelView<Factory> {
        let channelController = utils.channelControllerFactory
            .makeChannelController(for: channel.cid)

        var messageController: ChatMessageController?
        if let parentMessageId = message.parentMessageId {
            messageController = chatClient.messageController(
                cid: channel.cid,
                messageId: parentMessageId
            )
        }

        return ChatChannelView(
            viewFactory: factory,
            channelController: channelController,
            messageController: messageController,
            scrollToMessage: message
        )
    }
}

struct PinnedMessageView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private let avatarSize = CGSize(width: 56, height: 56)

    var factory: Factory
    var message: ChatMessage
    var channel: ChatChannel

    var body: some View {
        HStack {
            factory.makeMessageAvatarView(
                for: UserDisplayInfo(
                    id: message.author.id,
                    name: message.author.name ?? "",
                    imageURL: message.author.imageURL,
                    size: avatarSize,
                    extraData: message.author.extraData
                )
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(message.author.name ?? message.author.id)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.text))

                HStack {
                    Text(pinnedMessageSubtitle)
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.textLowEmphasis))

                    Spacer()

                    SubtitleText(
                        text: utils.messageRelativeDateFormatter.string(from: message.createdAt)
                    )
                }
            }
        }
        .padding(.all, 8)
    }
    
    private var pinnedMessageSubtitle: String {
        if message.poll != nil {
            return "📊 \(L10n.Channel.Item.poll)"
        }
        let messageFormatter = InjectedValues[\.utils].messagePreviewFormatter
        return messageFormatter.formatAttachmentContent(for: message, in: channel) ?? message.adjustedText
    }
}
