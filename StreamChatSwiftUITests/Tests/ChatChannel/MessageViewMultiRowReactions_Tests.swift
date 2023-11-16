//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

final class MessageViewMultiRowReactions_Tests: StreamChatTestCase {

    override public func setUp() {
        super.setUp()
        let reactionsTopPadding: (ChatMessage) -> CGFloat = { message in
            let padding: CGFloat = 8
            var paddingOffset: CGFloat = 0
            let rowSize: CGFloat = 24
            let chunkSize: CGFloat = 2
            let reactionsCount = CGFloat(message.reactionScores.count)
            let numberOfRows = ceil(reactionsCount / chunkSize)
            if numberOfRows > 1 {
                paddingOffset = (numberOfRows - 1) * padding
            }
            return numberOfRows * rowSize + paddingOffset
        }
        let messageDisplayOptions = MessageDisplayOptions(reactionsTopPadding: reactionsTopPadding)
        let utils = Utils(
            dateFormatter: EmptyDateFormatter(),
            messageListConfig: MessageListConfig(messageDisplayOptions: messageDisplayOptions)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }
    
    func test_messageViewMultiRowReactions_snapshot() {
        // Given
        let viewFactory = TestViewFactory.shared
        let message = ChatMessage.mock(
            text: "Test message",
            reactionScores: [
                .init(rawValue: "love"): 1,
                .init(rawValue: "like"): 1,
                .init(rawValue: "haha"): 1
            ]
        )
        let channel = ChatChannel.mockDMChannel()
        
        // When
        let view = MessageContainerView(
            factory: viewFactory,
            channel: channel,
            message: message,
            showsAllInfo: true,
            isInThread: false,
            isLast: true,
            scrolledId: .constant(nil),
            quotedMessage: .constant(nil),
            onLongPress: { _ in }
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}

class TestViewFactory: ViewFactory {

    @Injected(\.chatClient) public var chatClient

    private init() {}

    public static let shared = TestViewFactory()
    
    func makeMessageReactionView(
        message: ChatMessage,
        onTapGesture: @escaping () -> Void,
        onLongPressGesture: @escaping () -> Void
    ) -> some View {
        CustomReactionsContainer(message: message, onTapGesture: onTapGesture, onLongPressGesture: onLongPressGesture)
    }
}

struct CustomReactionsContainer: View {
    
    @Injected(\.utils) var utils
    
    let chunkSize = 2
    
    let message: ChatMessage
    var useLargeIcons = false
    var onTapGesture: () -> Void
    var onLongPressGesture: () -> Void
    
    var messageDisplayOptions: MessageDisplayOptions {
        utils.messageListConfig.messageDisplayOptions
    }

    var body: some View {
        GeometryReader { reader in
            Color.clear
                .overlay(
                    ReactionsHStack(message: message) {
                        CustomMessageReactionView(
                            message: message,
                            chunkSize: chunkSize,
                            useLargeIcons: useLargeIcons,
                            reactions: reactions,
                            onReactionTap: { _ in }
                        )
                        .onTapGesture {
                            onTapGesture()
                        }
                        .onLongPressGesture {
                            onLongPressGesture()
                        }
                    }
                    .offset(
                        x: offsetX,
                        y: (-reader.size.height - offsetY) / 2
                    )
                )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ReactionsContainer")
    }

    private var reactions: [MessageReactionType] {
        message.reactionScores.keys.filter { reactionType in
            (message.reactionScores[reactionType] ?? 0) > 0
        }
        .sorted(by: { lhs, rhs in
            lhs.rawValue < rhs.rawValue
        })
    }
    
    private var offsetY: CGFloat {
        let topPadding = utils.messageListConfig.messageDisplayOptions.reactionsTopPadding(message)
        let extraPadding: CGFloat = 10
        return topPadding - extraPadding
    }

    private var reactionsSize: CGFloat {
        let entrySize = 32
        var count = message.reactionScores.count
        if count > chunkSize {
            count = chunkSize
        }
        return CGFloat(count * entrySize)
    }

    private var offsetX: CGFloat {
        var offset = reactionsSize / 3
        if message.reactionScores.count == 1 {
            offset = 16
        }
        return message.isSentByCurrentUser ? -offset : offset
    }
}

struct ReactionsRow: Identifiable {
    let id: Int // the row index
    let reactions: [MessageReactionType]
}

struct CustomMessageReactionView: View {

    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    let message: ChatMessage
    let chunkSize: Int
    var useLargeIcons = false
    var reactionsRows: [ReactionsRow] = []
    var onReactionTap: (MessageReactionType) -> Void

    public init(
        message: ChatMessage,
        chunkSize: Int,
        useLargeIcons: Bool = false,
        reactions: [MessageReactionType],
        onReactionTap: @escaping (MessageReactionType) -> Void
    ) {
        self.message = message
        self.useLargeIcons = useLargeIcons
        self.chunkSize = chunkSize
        // self.reactionsRows = reactions.sorted().gridByRows().enumerated().map(ReactionsRow.init(id:reactions:))
        self.onReactionTap = onReactionTap
        let chunks = reactions.chunks(chunkSize: chunkSize)
        for i in 0..<chunks.count {
            reactionsRows.append(ReactionsRow(id: i, reactions: chunks[i]))
        }
    }

    var body: some View {

        VStack {
            ForEach(reactionsRows) { reactionsRow in
                HStack {
                    ForEach(reactionsRow.reactions) { reaction in
                        if let image = iconProvider(for: reaction) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(color(for: reaction))
                                .frame(width: useLargeIcons ? 25 : 20, height: useLargeIcons ? 27 : 20)
                                .gesture(
                                    useLargeIcons ?
                                        TapGesture().onEnded {
                                            onReactionTap(reaction)
                                        } : nil
                                )
                                .accessibilityIdentifier("reaction-\(reaction.id)")
                        }
                    }
                }
            }
        }
        .padding(.all, 6)
        .padding(.horizontal, 4)
        .reactionsBubble(for: message)
    }

    private func iconProvider(for reaction: MessageReactionType) -> UIImage? {
        if useLargeIcons {
            return images.availableReactions[reaction]?.largeIcon
        } else {
            return images.availableReactions[reaction]?.smallIcon
        }
    }

    private func color(for reaction: MessageReactionType) -> Color? {
        var colors = colors
        let containsUserReaction = userReactionIDs.contains(reaction)
        let color = containsUserReaction ? colors.reactionCurrentUserColor : colors.reactionOtherUserColor

        if let color = color {
            return Color(color)
        } else {
            return nil
        }
    }

    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}

extension Array {

    func chunks(chunkSize: Int) -> [[Element]] {
        stride(from: 0, to: count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
