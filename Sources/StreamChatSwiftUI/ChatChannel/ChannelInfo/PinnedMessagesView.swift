//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying pinned messages in the chat info screen.
public struct PinnedMessagesView<Factory: ViewFactory>: View {
    
    @Injected(\.images) private var images

    @StateObject private var viewModel: PinnedMessagesViewModel
    
    let factory: Factory

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
        self.factory = factory
    }

    public var body: some View {
        ZStack {
            if !viewModel.pinnedMessages.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.pinnedMessages) { message in
                            PinnedMessageView(factory: factory, message: message, channel: viewModel.channel)
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
        .navigationTitle(L10n.ChatInfo.PinnedMessages.title)
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
                    size: avatarSize
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
                        text: utils.dateFormatter.string(from: message.createdAt)
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
        return messageFormatter.formatAttachmentContent(for: message) ?? message.adjustedText
    }
}
