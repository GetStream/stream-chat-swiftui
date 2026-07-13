//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor
final class MentionSuggestion_Tests: StreamChatTestCase {
    // MARK: - id

    func test_id_isUniquePerSuggestion() {
        let user = ChatUser.mock(id: "u1", name: "John")
        let role = Role(createdAt: .unique, custom: false, name: "admin", scopes: [], updatedAt: .unique)
        let group = UserGroup.mock(id: "g1", name: "Dream Team")

        XCTAssertEqual(MentionSuggestion.user(user).id, "user-u1")
        XCTAssertEqual(MentionSuggestion.here.id, "broadcast-here")
        XCTAssertEqual(MentionSuggestion.channel.id, "broadcast-channel")
        XCTAssertEqual(MentionSuggestion.role(role).id, "role-admin")
        XCTAssertEqual(MentionSuggestion.group(group).id, "group-g1")
    }

    // MARK: - kind

    func test_kind_matchesExpectedType() {
        XCTAssertTrue(MentionSuggestion.user(.mock(id: "u1")).kind is MentionSuggestion.User)
        XCTAssertTrue(MentionSuggestion.here.kind is MentionSuggestion.Here)
        XCTAssertTrue(MentionSuggestion.channel.kind is MentionSuggestion.Channel)
        XCTAssertTrue(MentionSuggestion.role(Role(createdAt: .unique, custom: false, name: "admin", scopes: [], updatedAt: .unique)).kind is MentionSuggestion.Role)
        XCTAssertTrue(MentionSuggestion.group(.mock(id: "g1", name: "Group")).kind is MentionSuggestion.Group)
    }

    // MARK: - mentionText

    func test_mentionText_returnsExpectedText() {
        let handler = makeHandler()
        let user = ChatUser.mock(id: "u1", name: "John Appleseed")
        XCTAssertEqual(handler.mentionText(for: .user(user)), user.mentionText)
        XCTAssertEqual(handler.mentionText(for: .here), "here")
        XCTAssertEqual(handler.mentionText(for: .channel), "channel")
        XCTAssertEqual(handler.mentionText(for: .role(Role(createdAt: .unique, custom: false, name: "moderator", scopes: [], updatedAt: .unique))), "moderator")
        XCTAssertEqual(handler.mentionText(for: .group(.mock(id: "g1", name: "Dream Team"))), "Dream Team")
    }

    // MARK: - private

    private func makeHandler() -> MentionsCommandHandler {
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        return MentionsCommandHandler(
            channelController: channelController,
            commandSymbol: "@"
        )
    }
}

private extension UserGroup {
    static func mock(id: String, name: String, memberCount: Int = 0) -> UserGroup {
        UserGroup(
            id: id,
            name: name,
            members: (0..<memberCount).map {
                UserGroupMember(groupId: id, userId: "member-\($0)", isAdmin: false, createdAt: .init())
            },
            createdAt: .init(),
            updatedAt: .init()
        )
    }
}
