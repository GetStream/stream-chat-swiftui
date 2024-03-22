//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying pinned messages in the chat info screen.
public struct PinnedMessagesView: View {

    @StateObject private var viewModel: PinnedMessagesViewModel

    public init(channel: ChatChannel, channelController: ChatChannelController? = nil) {
        _viewModel = StateObject(
            wrappedValue: PinnedMessagesViewModel(
                channel: channel,
                channelController: channelController
            )
        )
    }

    public var body: some View {
        ZStack {
            if !viewModel.pinnedMessages.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.pinnedMessages) { message in
                            PinnedMessageView(message: message)
                            Divider()
                        }
                    }
                }
            } else {
                NoContentView(
                    imageName: "message",
                    title: L10n.ChatInfo.PinnedMessages.emptyTitle,
                    description: L10n.ChatInfo.PinnedMessages.emptyDesc,
                    shouldRotateImage: true
                )
            }
        }
        .navigationTitle(L10n.ChatInfo.PinnedMessages.title)
    }
}

struct PinnedMessageView: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private let avatarSize = CGSize(width: 56, height: 56)

    var message: ChatMessage

    var body: some View {
        HStack {
            MessageAvatarView(
                avatarURL: message.author.imageURL,
                size: avatarSize
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(message.author.name ?? message.author.id)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.text))

                HStack {
                    Text(message.adjustedText)
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
}
