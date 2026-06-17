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

    // MARK: - type

    func test_type_matchesCase() {
        XCTAssertEqual(MentionSuggestion.user(.mock(id: "u1")).type, .user)
        XCTAssertEqual(MentionSuggestion.here.type, .here)
        XCTAssertEqual(MentionSuggestion.channel.type, .channel)
        XCTAssertEqual(MentionSuggestion.role(Role(name: "admin")).type, .role)
        XCTAssertEqual(MentionSuggestion.group(.mock(id: "g1", name: "Group")).type, .group)
    }

    // MARK: - mentionText

    func test_mentionText_returnsTextAfterAtSign() {
        let user = ChatUser.mock(id: "u1", name: "John Appleseed")
        XCTAssertEqual(MentionSuggestion.user(user).mentionText, user.mentionText)
        XCTAssertEqual(MentionSuggestion.here.mentionText, "here")
        XCTAssertEqual(MentionSuggestion.channel.mentionText, "channel")
        XCTAssertEqual(MentionSuggestion.role(Role(name: "moderator")).mentionText, "moderator")
        XCTAssertEqual(MentionSuggestion.group(.mock(id: "g1", name: "Dream Team")).mentionText, "Dream Team")
    }

    // MARK: - MentionSuggestionsConfig

    func test_defaultConfig_onlyAllowsUsers() {
        let config = MentionSuggestionsConfig.default
        XCTAssertEqual(config.allowedMentionTypes, [.user])
        XCTAssertFalse(config.mentionAllAppUsers)
    }

    func test_enhancedConfig_allowsAllMentionTypes() {
        let config = MentionSuggestionsConfig.enhanced
        XCTAssertEqual(config.allowedMentionTypes, MentionType.allBuiltIn)
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
