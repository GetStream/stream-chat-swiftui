//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

final class MentionSuggestion_Tests: XCTestCase {
    // MARK: - id

    func test_id_isUniquePerSuggestion() {
        let user = ChatUser.mock(id: "u1", name: "John")
        let role = Role(name: "admin")
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
        XCTAssertTrue(MentionSuggestion.role(Role(name: "admin")).kind is MentionSuggestion.Role)
        XCTAssertTrue(MentionSuggestion.group(.mock(id: "g1", name: "Group")).kind is MentionSuggestion.Group)
    }

    // MARK: - mentionText

    func test_mentionText_returnsExpectedText() {
        let user = ChatUser.mock(id: "u1", name: "John Appleseed")
        XCTAssertEqual(MentionsCommandHandler.mentionText(for: .user(user)), user.mentionText)
        XCTAssertEqual(MentionsCommandHandler.mentionText(for: .here), "here")
        XCTAssertEqual(MentionsCommandHandler.mentionText(for: .channel), "channel")
        XCTAssertEqual(MentionsCommandHandler.mentionText(for: .role(Role(name: "moderator"))), "moderator")
        XCTAssertEqual(MentionsCommandHandler.mentionText(for: .group(.mock(id: "g1", name: "Dream Team"))), "Dream Team")
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
