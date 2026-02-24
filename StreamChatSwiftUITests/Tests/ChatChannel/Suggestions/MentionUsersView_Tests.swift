//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor
final class MentionUsersView_Tests: StreamChatTestCase {
    func test_mentionUsersView_default() {
        let users = mockUsers(count: 3)
        let view = MentionUsersView(users: users, userSelected: { _ in })
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    func test_mentionUsersView_singleUser() {
        let users = mockUsers(count: 1)
        let view = MentionUsersView(users: users, userSelected: { _ in })
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight])
    }

    func test_mentionUsersView_maxHeight() {
        let users = mockUsers(count: 8)
        let view = MentionUsersView(users: users, userSelected: { _ in })
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight])
    }

    func test_messageComposerView_emptyMentions() {
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.composerCommand = ComposerCommand(
            id: "mentions",
            typingSuggestion: .empty,
            displayInfo: nil
        )

        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        .frame(width: defaultScreenSize.width, height: 200)

        AssertSnapshot(view, variants: [.defaultLight])
    }

    private func mockUsers(count: Int) -> [ChatUser] {
        let names = ["Elena Barros", "Emma Chen", "Lina Park", "Noah Richter", "Wesley Lau", "Ana Silva", "John Doe", "Jane Smith"]
        return (0..<count).map { i in
            ChatUser.mock(id: "user-\(i)", name: names[i % names.count])
        }
    }
}
