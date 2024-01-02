//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatUserNamer_Tests: XCTestCase {
    func test_defaultChatUserNamer_whenUserHasName_showsStringName() {
        // Given
        let chatUser = ChatUser.mock(id: .unique, name: "Darth Vader")

        // When
        let defaultChatUserNamer = DefaultChatUserNamer()
        let userNameString = defaultChatUserNamer.name(forUser: chatUser)

        // Then
        guard let userNameString = userNameString else {
            XCTFail()
            return
        }

        XCTAssertEqual(userNameString, "Darth Vader")
    }

    func test_defaultChatUserNamer_whenUserHasNoName_showsNil() {
        // Given
        let chatUser = ChatUser.mock(id: .unique, name: nil)

        // When
        let defaultChatUserNamer = DefaultChatUserNamer()
        let userNameString = defaultChatUserNamer.name(forUser: chatUser)

        // Then
        XCTAssertNil(userNameString)
    }
}
