//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the giphy attachments.
public struct GiphyAttachmentView<Factory: ViewFactory>: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

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
            if let quotedMessage = message.quotedMessage {
                factory.makeQuotedMessageView(
                    options: QuotedMessageViewOptions(
                        quotedMessage: quotedMessage,
                        fillAvailableSpace: !message.attachmentCounts.isEmpty,
                        isInComposer: false,
                        scrolledId: $scrolledId
                    )
                )
            }

            LazyGiphyView(
                source: message.giphyAttachments[0].previewURL,
                width: width
            )
            .overlay(
                factory.makeGiphyBadgeViewType(
                    options: GiphyBadgeViewTypeOptions(
                        message: message,
                        availableWidth: width
                    )
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
                if imageContainer.type == .gif {
                    AnimatedGifView(imageContainer: imageContainer)
                        .frame(width: width)
                } else {
                    state.image
                }
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

/// Recommended implementation by SwiftyGif for rendering gifs in SwiftUI
/// Nuke dropped gif support and therefore it needs to be implemented separately.
private struct AnimatedGifView: UIViewRepresentable {
    let imageContainer: ImageContainer

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        if let gifData = imageContainer.data, let image = try? UIImage(gifData: gifData) {
            imageView.setGifImage(image)
        }
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}
