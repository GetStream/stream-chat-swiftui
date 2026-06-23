//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

final class UserAvatar_Tests: StreamChatTestCase {
    func test_userAvatar_placeholders() async throws {
        // Given
        let size = CGSize(width: 320, height: 320)
        let view = HStack(spacing: 2) {
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "EC",
                        size: size,
                        indicator: .online
                    )
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "",
                        size: size,
                        indicator: .offline
                    )
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "",
                        size: size,
                        indicator: .offline
                    )
                    .redacted(reason: .placeholder)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }

    // MARK: - Initials

    func test_initials_returnsExpectedInitials() {
        XCTAssertEqual(UserAvatar.initials(from: "John Doe"), "JD")
        XCTAssertEqual(UserAvatar.initials(from: "Jane Smith"), "JS")
    }

    func test_initials_emptyName_returnsEmptyString() {
        XCTAssertEqual(UserAvatar.initials(from: ""), "")
    }

    func test_initials_repeatedCalls_returnSameValue() {
        // The second lookup is served from the cache and must match the first.
        let first = UserAvatar.initials(from: "Ada Lovelace")
        let second = UserAvatar.initials(from: "Ada Lovelace")
        XCTAssertEqual(first, second)
    }

    func test_initials_caching_doesNotLeakBetweenNames() {
        // Interleaving distinct names must not return another name's cached value.
        let firstBefore = UserAvatar.initials(from: "Grace Hopper")
        let other = UserAvatar.initials(from: "Alan Turing")
        let firstAfter = UserAvatar.initials(from: "Grace Hopper")
        XCTAssertEqual(firstBefore, firstAfter)
        XCTAssertNotEqual(firstBefore, other)
    }
}
