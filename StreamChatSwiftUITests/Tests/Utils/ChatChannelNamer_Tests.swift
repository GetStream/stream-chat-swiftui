//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelNamer_Tests: XCTestCase {

    var defaultMembers: [ChatChannelMember]!

    override func setUp() {
        super.setUp()

        defaultMembers = [
            .mock(
                id: .unique,
                name: "Darth Vader",
                imageURL: nil,
                isOnline: true
            ),
            .mock(
                id: .unique,
                name: "Darth Maul",
                imageURL: nil,
                isOnline: true
            ),
            .mock(
                id: .unique,
                name: "Kylo Ren",
                imageURL: nil,
                isOnline: true
            )
        ]
    }

    func test_defaultChannelNamer_whenChannelHasName_showsChannelName() {
        // Given
        let channel = ChatChannel.mock(
            cid: .unique,
            name: "Darth Channel",
            imageURL: URL(string: "https://example.com")!,
            lastActiveMembers: defaultMembers
        )
        let currentUserId: String = .unique
        let namer: ChatChannelNamer = DefaultChatChannelNamer()

        // When
        let nameForChannel = namer(channel, currentUserId)

        // Then
        XCTAssertEqual(nameForChannel, "Darth Channel")
    }

    func test_defaultChannelNamer_directChannel_whenChannelHasNoName_andExactly2Members_showsCurrentMembers() {
        // Given
        defaultMembers = [
            .mock(
                id: .unique,
                name: "Darth Vader",
                imageURL: nil,
                isOnline: true
            ),
            .mock(
                id: .unique,
                name: "Darth Maul",
                imageURL: nil,
                isOnline: true
            )
        ]
        let channel = ChatChannel.mockDMChannel(
            name: nil,
            lastActiveMembers: defaultMembers
        )
        let currentUserId: String = .unique
        let namer: ChatChannelNamer = DefaultChatChannelNamer()

        // When
        let nameForChannel = namer(channel, currentUserId)

        // Then
        XCTAssertEqual(nameForChannel, "Darth Maul and Darth Vader")
    }

    func test_defaultChannelNamer_directChannel_whenChannelHasNoName_whenChannelHasNoMembers_showsCurrentUserId() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            name: nil
        )
        let currentUserId: String = .unique
        let namer: ChatChannelNamer = DefaultChatChannelNamer()

        // When
        let nameForChannel = namer(channel, currentUserId)

        // Then
        XCTAssertEqual(nameForChannel, nil)
    }

    func test_defaultChannelNamer_directChannel_whenChannelHasNoName_whenChannelHasOnlyCurrentMember_showsCurrentMemberName() {
        // Given
        let currentUser: ChatChannelMember = .mock(id: .unique, name: "Luke Skywalker")
        let channel = ChatChannel.mockDMChannel(
            name: nil,
            lastActiveMembers: [currentUser]
        )
        let currentUserId: String = currentUser.id
        let namer: ChatChannelNamer = DefaultChatChannelNamer()

        // When
        let nameForChannel = namer(channel, currentUserId)

        // Then
        XCTAssertEqual(nameForChannel, currentUser.name)
    }

    func test_defaultChannelNamer_directChannel_whenChannelHasNoName_andMoreThan2Members_showsMembersAndNMore() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            name: nil,
            lastActiveMembers: defaultMembers
        )
        let currentUserId: String = .unique
        let namer: ChatChannelNamer = DefaultChatChannelNamer()

        // When
        let nameForChannel = namer(channel, currentUserId)

        // Then
        XCTAssertEqual(nameForChannel, "Darth Maul, Darth Vader and 1 more")
    }

    func test_defaultChannelNamer_whenChannelHasNoName_AndNotDM_returnsNil() {
        // Given
        let channelID: String = .unique
        let channel = ChatChannel.mock(
            cid: ChannelId(type: .gaming, id: channelID),
            name: nil
        )
        let currentUserId: String = .unique
        let namer: ChatChannelNamer = DefaultChatChannelNamer()

        // When
        let nameForChannel = namer(channel, currentUserId)

        // Then
        XCTAssertEqual(nameForChannel, nil)
    }

    func test_defaultChannelNamer_withModifiedParameters_customSeparator() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            name: nil,
            lastActiveMembers: defaultMembers
        )
        let currentUserId: String = .unique
        let namer: ChatChannelNamer = DefaultChatChannelNamer(separator: " |")

        // When
        let nameForChannel = namer(channel, currentUserId)

        // Then
        XCTAssertEqual(nameForChannel, "Darth Maul | Darth Vader and 1 more")
    }

    func test_defaultChannelNamer_withModifiedParameters_numberOfMaximumMembers() {
        // Given
        defaultMembers = [
            .mock(
                id: .unique,
                name: "Darth Vader",
                imageURL: nil,
                isOnline: true
            ),
            .mock(
                id: .unique,
                name: "Darth Maul",
                imageURL: nil,
                isOnline: true
            ),
            .mock(
                id: .unique,
                name: "Kylo Ren",
                imageURL: nil,
                isOnline: true
            ),
            .mock(
                id: .unique,
                name: "Darth Bane",
                imageURL: nil,
                isOnline: true
            )
        ]
        let channel = ChatChannel.mockDMChannel(
            name: nil,
            lastActiveMembers: defaultMembers
        )
        let currentUserId: String = .unique
        let namer: ChatChannelNamer = DefaultChatChannelNamer(maxMemberNames: 4, separator: " |")

        // When
        let nameForChannel = namer(channel, currentUserId)

        // Then
        XCTAssertEqual(nameForChannel, "Darth Bane | Darth Maul | Darth Vader | Kylo Ren")
    }
}
