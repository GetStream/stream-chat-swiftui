//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying single user reaction.
struct ReactionUserView: View {

    @Injected(\.chatClient) private var chatClient
    @Injected(\.fonts) private var fonts

    var reaction: ChatMessageReaction
    var imageSize: CGFloat

    private var isCurrentUser: Bool {
        chatClient.currentUserId == reaction.author.id
    }

    private var authorName: String {
        if isCurrentUser {
            return L10n.Message.Reactions.currentUser
        } else {
            return reaction.author.name ?? reaction.author.id
        }
    }

    var body: some View {
        VStack {
            MessageAvatarView(
                avatarURL: reaction.author.imageURL,
                size: CGSize(width: imageSize, height: imageSize),
                showOnlineIndicator: false
            )
            .overlay(
                VStack {
                    Spacer()
                    SingleReactionView(reaction: reaction)
                        .frame(height: imageSize / 2)
                }
            )

            Text(authorName)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .font(fonts.footnoteBold)
                .frame(width: imageSize)
        }
        .padding(.vertical)
        .padding(.horizontal, 8)
    }
}

/// Helper view displaying the reaction overlay.
struct SingleReactionView: View {

    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.chatClient) private var chatClient

    var reaction: ChatMessageReaction

    private var isSentByCurrentUser: Bool {
        reaction.author.id == chatClient.currentUserId
    }

    private var backgroundColor: Color {
        isSentByCurrentUser ? Color(colors.background) : Color(colors.background6)
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                if !isSentByCurrentUser {
                    Spacer()
                }

                if let image = images.availableReactions[reaction.type]?.largeIcon {
                    VStack(spacing: 0) {
                        ReactionImageView(
                            image: image,
                            isSentByCurrentUser: isSentByCurrentUser,
                            backgroundColor: backgroundColor
                        )

                        ReactionBubbles(
                            isSentByCurrentUser: isSentByCurrentUser,
                            backgroundColor: backgroundColor
                        )
                        .offset(x: isSentByCurrentUser ? 8 : -8, y: -14)
                    }
                }

                if isSentByCurrentUser {
                    Spacer()
                }
            }
        }
    }
}

/// View displaying the reaction image.
struct ReactionImageView: View {

    @Injected(\.colors) private var colors

    var image: UIImage
    var isSentByCurrentUser: Bool
    var backgroundColor: Color

    private var reactionColor: UIColor? {
        var colors = colors
        return isSentByCurrentUser ? colors.reactionCurrentUserColor : colors.reactionOtherUserColor
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .foregroundColor(reactionColor != nil ? Color(reactionColor!) : nil)
            .frame(width: 16, height: 16)
            .padding(.all, 8)
            .background(backgroundColor)
            .overlay(
                Circle()
                    .strokeBorder(
                        Color(colors.innerBorder),
                        lineWidth: 1
                    )
            )
            .clipShape(Circle())
    }
}

/// View bubbles shown at the bottom of a reaction.
struct ReactionBubbles: View {

    @Injected(\.colors) private var colors

    var isSentByCurrentUser: Bool
    var backgroundColor: Color

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Circle()
                .fill(backgroundColor)
                .frame(width: 8, height: 8)
            Circle()
                .fill(backgroundColor)
                .frame(width: 4, height: 4)
        }
        .rotationEffect(.degrees(isSentByCurrentUser ? -45 : 45))
    }
}
