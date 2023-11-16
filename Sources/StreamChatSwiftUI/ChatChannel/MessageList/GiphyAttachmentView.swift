//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the giphy attachments.
public struct GiphyAttachmentView<Factory: ViewFactory>: View {

    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils

    let factory: Factory
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    @Binding var scrolledId: String?

    public var body: some View {
        VStack(
            alignment: message.alignmentInBubble,
            spacing: 0
        ) {
            if let quotedMessage = utils.messageCachingUtils.quotedMessage(for: message) {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
            }

            LazyGiphyView(
                source: message.giphyAttachments[0].previewURL,
                width: width
            )
            .overlay(
                factory.makeGiphyBadgeViewType(
                    for: message,
                    availableWidth: width
                )
            )

            if !giphyActions.isEmpty {
                HStack {
                    ForEach(0..<giphyActions.count, id: \.self) { index in
                        let action = giphyActions[index]
                        Button {
                            execute(action: action)
                        } label: {
                            Text(action.value.firstUppercased)
                                .padding(.horizontal, 4)
                                .padding(.vertical)
                        }
                        .foregroundColor(
                            action.style == .primary ?
                                colors.tintColor :
                                Color(colors.textLowEmphasis)
                        )
                        .font(fonts.bodyBold)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message,
                    isFirst: isFirst
                )
            )
        )
        .frame(maxWidth: width)
        .accessibilityIdentifier("GiphyAttachmentView")
    }

    private var giphyActions: [AttachmentAction] {
        message.giphyAttachments[0].actions
    }

    private func execute(action: AttachmentAction) {
        guard let cid = message.cid else {
            log.error("Failed to take the tap on attachment action \(action)")
            return
        }

        chatClient
            .messageController(
                cid: cid,
                messageId: message.id
            )
            .dispatchEphemeralMessageAction(action)
    }
}

struct LazyGiphyView: View {
    let source: URL
    let width: CGFloat

    var body: some View {
        LazyImage(imageURL: source) { state in
            if let imageContainer = state.imageContainer {
                NukeImage(imageContainer)
            } else if state.error != nil {
                Color(.secondarySystemBackground)
            } else {
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            }
        }
        .onDisappear(.cancel)
        .processors([ImageProcessors.Resize(width: width)])
        .priority(.high)
        .aspectRatio(contentMode: .fit)
    }
}
