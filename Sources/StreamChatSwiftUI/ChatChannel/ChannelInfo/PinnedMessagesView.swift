//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
            if viewModel.isLoading {
                ProgressView()
            } else if !viewModel.pinnedMessages.isEmpty {
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
                EmptyContentView(
                    image: images.pin,
                    title: L10n.ChatInfo.PinnedMessages.emptyTitle,
                    description: L10n.ChatInfo.PinnedMessages.emptyDesc
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
    @Injected(\.tokens) private var tokens

    private let avatarSize: CGFloat = AvatarSize.large

    var factory: Factory
    var message: ChatMessage
    var channel: ChatChannel

    var body: some View {
        HStack {
            factory.makeUserAvatarView(
                options: .init(
                    user: message.author,
                    size: avatarSize,
                    showsIndicator: false
                )
            )

            VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                Text(message.author.name ?? message.author.id)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.text))

                HStack {
                    HStack(spacing: tokens.spacingXxs) {
                        attachmentIconView
                        Text(pinnedMessageSubtitle)
                    }
                    .lineLimit(1)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))

                    Spacer()

                    SubtitleText(
                        text: utils.messageTimestampFormatter.format(message.createdAt)
                    )
                }
            }
        }
        .padding(.all, tokens.spacingMd)
    }

    private var previewAttachmentIconImage: UIImage? {
        let resolver = MessageAttachmentPreviewResolver(message: message)
        guard let previewIcon = resolver.previewIcon else { return nil }
        return utils.messageAttachmentPreviewIconProvider.image(for: previewIcon)
    }

    @ViewBuilder
    private var attachmentIconView: some View {
        if let iconImage = previewAttachmentIconImage {
            Image(uiImage: iconImage)
                .customizable()
                .frame(maxHeight: 12)
                .accessibilityHidden(true)
        }
    }

    private var pinnedMessageSubtitle: String {
        let messageFormatter = utils.messagePreviewFormatter
        return messageFormatter.formatAttachmentContent(for: message, in: channel) ?? message.adjustedText
    }
}
