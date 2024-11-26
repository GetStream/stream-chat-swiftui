//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class CreatePollView_Tests: StreamChatTestCase {

    func test_createPollView_snapshot() {
        // Given
        let view = CreatePollView(
            chatController: .init(channelQuery: .init(cid: .unique), channelListQuery: nil, client: chatClient),
            messageController: nil
        )
        .applyDefaultSize()
        
        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_createPollView_allOptionsDisabledSnapshot() {
        // Given
        let hidden = PollsEntryConfig(configurable: false, defaultValue: false)
        streamChat?.utils.pollsConfig = PollsConfig(
            multipleAnswers: hidden,
            anonymousPoll: hidden,
            suggestAnOption: hidden,
            addComments: hidden
        )
        let view = CreatePollView(
            chatController: .init(channelQuery: .init(cid: .unique), channelListQuery: nil, client: chatClient),
            messageController: nil
        )
        .applyDefaultSize()
        
        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }
    
    func test_createPollView_allOptionsEnabledSnapshot() {
        // Given
        let enabled = PollsEntryConfig(configurable: true, defaultValue: true)
        streamChat?.utils.pollsConfig = PollsConfig(
            multipleAnswers: enabled,
            anonymousPoll: enabled,
            suggestAnOption: enabled,
            addComments: enabled,
            maxVotesPerPerson: enabled
        )
        let view = CreatePollView(
            chatController: .init(channelQuery: .init(cid: .unique), channelListQuery: nil, client: chatClient),
            messageController: nil
        )
        .applyDefaultSize()
        
        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }
    
    func test_createPollView_mixedOptionsSnapshot() {
        // Given
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
        let view = CreatePollView(
            chatController: .init(channelQuery: .init(cid: .unique), channelListQuery: nil, client: chatClient),
            messageController: nil
        )
        .applyDefaultSize()
        
        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }
}
