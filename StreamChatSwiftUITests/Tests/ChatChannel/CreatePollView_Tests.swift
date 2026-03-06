//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class CreatePollView_Tests: StreamChatTestCase {
    private func makeCreatePollView() -> CreatePollView {
        CreatePollView(
            chatController: .init(channelQuery: .init(cid: .unique), channelListQuery: nil, client: chatClient),
            messageController: nil
        )
    }

    func test_createPollView_snapshot() {
        let view = makeCreatePollView().applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_createPollView_allOptionsDisabledSnapshot() {
        let hidden = PollsEntryConfig(configurable: false, defaultValue: false)
        streamChat?.utils.pollsConfig = PollsConfig(
            multipleAnswers: hidden,
            anonymousPoll: hidden,
            suggestAnOption: hidden,
            addComments: hidden,
            maxVotesPerPerson: hidden
        )
        let view = makeCreatePollView().applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_createPollView_allOptionsEnabledSnapshot() {
        let enabled = PollsEntryConfig(configurable: true, defaultValue: true)
        streamChat?.utils.pollsConfig = PollsConfig(
            multipleAnswers: enabled,
            anonymousPoll: enabled,
            suggestAnOption: enabled,
            addComments: enabled,
            maxVotesPerPerson: enabled
        )
        let view = makeCreatePollView().applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_createPollView_multipleVotesWithoutMaxVotesSnapshot() {
        let enabled = PollsEntryConfig(configurable: true, defaultValue: true)
        let hidden = PollsEntryConfig(configurable: false, defaultValue: false)
        streamChat?.utils.pollsConfig = PollsConfig(
            multipleAnswers: enabled,
            anonymousPoll: hidden,
            suggestAnOption: hidden,
            addComments: hidden,
            maxVotesPerPerson: hidden
        )
        let view = makeCreatePollView().applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_createPollView_mixedOptionsSnapshot() {
        let enabled = PollsEntryConfig(configurable: true, defaultValue: true)
        let hidden = PollsEntryConfig(configurable: false, defaultValue: false)
        let disabled = PollsEntryConfig(configurable: true, defaultValue: false)
        streamChat?.utils.pollsConfig = PollsConfig(
            multipleAnswers: enabled,
            anonymousPoll: hidden,
            suggestAnOption: disabled,
            addComments: disabled,
            maxVotesPerPerson: enabled
        )
        let view = makeCreatePollView().applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }
}
