//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displayed when a message is deleted.
public struct DeletedMessageView: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }
    
    private var deletedMessageVisibility: ChatClientConfig.DeletedMessageVisibility {
        chatClient.config.deletedMessagesVisibility
    }

    var message: ChatMessage
    var isFirst: Bool

    public var body: some View {
        VStack(
            alignment: message.isRightAligned ? .trailing : .leading,
            spacing: 4
        ) {
            Text(L10n.Message.deletedMessagePlaceholder)
                .font(fonts.body)
                .standardPadding()
                .foregroundColor(Color(colors.textLowEmphasis))
                .messageBubble(for: message, isFirst: isFirst)
                .accessibilityIdentifier("deletedMessageText")

            if message.isSentByCurrentUser {
                HStack {
                    if message.isRightAligned {
                        Spacer()
                    }

                    if deletedMessageVisibility == .visibleForCurrentUser {
                        Image(uiImage: images.eye)
                            .customizable()
                            .frame(maxWidth: 12)
                            .accessibilityIdentifier("onlyVisibleToYouImageView")

                        Text(L10n.Message.onlyVisibleToYou)
                            .font(fonts.footnote)
                            .accessibilityIdentifier("onlyVisibleToYouLabel")
                    }

                    Text(dateFormatter.string(from: message.createdAt))
                        .font(fonts.footnote)
                }
                .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("DeletedMessageView")
    }
}
