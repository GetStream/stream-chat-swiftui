//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI
import UIKit

@MainActor func showChannelWithMessageIdAction(channel: ChatChannel) -> ChannelAction {
    let action = ChannelAction(
        title: "Show channel with message id",
        iconName: "magnifyingglass",
        action: {},
        confirmationPopup: nil,
        isDestructive: false
    )
    action.navigationDestination = AnyView(ShowChannelWithMessageIdView(cid: channel.cid))
    return action
}

@MainActor func copyMessageIdAction(options: SupportedMessageActionsOptions) -> MessageAction {
    MessageAction(
        id: "copy_message_id_action",
        title: "Copy Message ID",
        iconName: "doc.on.doc",
        action: {
            UIPasteboard.general.string = options.message.id
            options.onFinish(MessageActionInfo(message: options.message, identifier: "copy_message_id"))
        },
        confirmationPopup: nil,
        isDestructive: false
    )
}

/// Opens a channel at the given message id, like jumping to a message search result.
struct ShowChannelWithMessageIdView: View {
    @Injected(\.chatClient) private var chatClient

    let cid: ChannelId

    @State private var messageId = ""
    @State private var message: ChatMessage?
    @State private var channelShown = false
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 16) {
            TextField("Message ID", text: $messageId)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .accessibilityIdentifier("MessageIdTextField")

            Button("Show channel") {
                showChannel()
            }
            .accessibilityIdentifier("ShowChannelWithMessageIdButton")

            if let errorText {
                Text(errorText)
            }

            Spacer()

            NavigationLink(isActive: $channelShown) {
                if let message {
                    ChatChannelView(
                        viewFactory: DemoAppFactory.shared,
                        channelController: chatClient.channelController(for: cid),
                        scrollToMessage: message
                    )
                }
            } label: {
                EmptyView()
            }
        }
        .padding()
    }

    private func showChannel() {
        let id = messageId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else { return }

        let messageController = chatClient.messageController(cid: cid, messageId: id)
        messageController.synchronize { error in
            guard error == nil, let loadedMessage = messageController.message, loadedMessage.cid == cid else {
                errorText = "Message ID does not belong to this channel"
                return
            }
            message = loadedMessage
            channelShown = true
        }
    }
}
