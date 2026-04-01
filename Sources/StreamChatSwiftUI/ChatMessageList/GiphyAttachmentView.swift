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
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens
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
            if let quotedMessage = message.quotedMessage {
                factory.makeChatQuotedMessageView(
                    options: ChatQuotedMessageViewOptions(
                        quotedMessage: quotedMessage,
                        parentMessage: message,
                        scrolledId: $scrolledId
                    )
                )
                .padding(tokens.spacingXs)
            }
            
            if visibleOnlyToCurrentUser {
                HStack {
                    Image(uiImage: images.onlyVisibleToCurrentUser)
                        .customizable()
                        .frame(width: tokens.iconSizeSm)
                    Text(L10n.Message.onlyVisibleToYou)
                        .font(fonts.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(colors.chatTextOutgoing.toColor)
                .padding(.all, tokens.spacingSm)
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

            if visibleOnlyToCurrentUser {
                HStack {
                    ForEach(0..<giphyActions.count, id: \.self) { index in
                        let action = giphyActions[index]
                        Button {
                            execute(action: action)
                        } label: {
                            Text(action.value.firstUppercased)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .padding(.horizontal, 4)
                                .padding(.vertical)
                        }
                        .foregroundColor(
                            action.style == .primary ?
                                Color(colors.buttonPrimaryText) :
                                Color(colors.buttonSecondaryText)
                        )
                        .font(fonts.bodyBold)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: width)
        .modifier(
            factory.styles.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message,
                    isFirst: isFirst,
                    injectedBackgroundColor: colors.highlightedAccentBackground1
                )
            )
        )
        .accessibilityIdentifier("GiphyAttachmentView")
    }
    
    private var visibleOnlyToCurrentUser: Bool {
        !giphyActions.isEmpty
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
                } else if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
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
        .frame(width: width, height: width)
        .clipped()
    }
}

/// Recommended implementation by SwiftyGif for rendering gifs in SwiftUI
/// Nuke dropped gif support and therefore it needs to be implemented separately.
/// The UIImageView is wrapped in a container with auto-layout constraints
/// to ensure contentMode scaling works correctly with SwiftyGif's
/// CADisplayLink-driven frame updates.
private struct AnimatedGifView: UIViewRepresentable {
    let imageContainer: ImageContainer

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.clipsToBounds = true

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        if let gifData = imageContainer.data, let image = try? UIImage(gifData: gifData) {
            imageView.setGifImage(image)
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
