//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor
final class MentionSuggestionsView_Tests: StreamChatTestCase {
    // MARK: - List

    func test_mentionSuggestionsView_regularStyle() {
        let view = MentionSuggestionsView(suggestions: allSuggestions(), suggestionSelected: { _ in })
            .modifier(SuggestionsRegularContainerModifier())
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view)
    }

    func test_mentionSuggestionsView_liquidGlassStyle() {
        let view = MentionSuggestionsView(suggestions: allSuggestions(), suggestionSelected: { _ in })
            .modifier(SuggestionsLiquidGlassContainerModifier())
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view)
    }

    // MARK: - Helpers

    private func allSuggestions() -> [MentionSuggestion] {
        [
            .here,
            .channel,
            .role(Role.mock(name: "admin")),
            .group(.mock(id: "g1", name: "Dream Team", memberCount: 4)),
            .user(.mock(id: "u1", name: "Elena Barros"))
        ]
    }
}

private extension UserGroup {
    static func mock(id: String, name: String, memberCount: Int = 0) -> UserGroup {
        UserGroup(
            createdAt: .init(),
            id: id,
            members: (0..<memberCount).map {
                UserGroupMember(createdAt: .init(), groupId: id, isAdmin: false, userId: "member-\($0)")
            },
            name: name,
            updatedAt: .init()
        )
    }
}
