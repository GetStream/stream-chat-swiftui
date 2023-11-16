//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying users who have reacted to a message.
struct ReactionsUsersView: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var message: ChatMessage
    var maxHeight: CGFloat

    private static let columnCount = 4
    private static let itemSize: CGFloat = 64

    private let columns = Array(
        repeating:
        GridItem(
            .adaptive(minimum: itemSize),
            alignment: .top
        ),
        count: columnCount
    )

    private var reactions: [ChatMessageReaction] {
        Array(message.latestReactions)
    }

    var body: some View {
        HStack {
            if message.isRightAligned {
                Spacer()
            }

            VStack(alignment: .center) {
                Text(L10n.Reaction.Authors.numberOfReactions(reactions.count))
                    .foregroundColor(Color(colors.text))
                    .font(fonts.title3)
                    .fontWeight(.bold)
                    .padding()

                if reactions.count > Self.columnCount {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                            ForEach(reactions) { reaction in
                                ReactionUserView(
                                    reaction: reaction,
                                    imageSize: Self.itemSize
                                )
                            }
                        }
                    }
                    .frame(maxHeight: maxHeight)
                } else {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(reactions) { reaction in
                            ReactionUserView(
                                reaction: reaction,
                                imageSize: Self.itemSize
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .background(Color(colors.background))
            .cornerRadius(16)

            if !message.isRightAligned {
                Spacer()
            }
        }
        .accessibilityIdentifier("ReactionsUsersView")
    }
}

extension ChatMessageReaction: Identifiable {

    public var id: String {
        "\(author.id)-\(type.rawValue)"
    }
}
