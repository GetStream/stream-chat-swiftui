//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class PollAttachmentViewModel_Tests: StreamChatTestCase {
    func test_hasMostVotes_whenWinningVote() {
        // Given
        let poll = Poll.mock(optionCount: 3, voteCountForOption: { optionIndex in
            switch optionIndex {
            case 0: return 2
            case 1: return 3
            case 2: return 1
            default: return 0
            }
        })
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            poll: poll
        )
        
        // When
        let viewModel = PollAttachmentViewModel(message: message, poll: poll)
        
        // Then
        XCTAssertEqual(viewModel.hasMostVotes(for: poll.options[0]), false)
        XCTAssertEqual(viewModel.hasMostVotes(for: poll.options[1]), true)
        XCTAssertEqual(viewModel.hasMostVotes(for: poll.options[2]), false)
    }
    
    func test_hasMostVotes_whenEqualHighestVotes() {
        // Given
        let poll = Poll.mock(optionCount: 3, voteCountForOption: { optionIndex in
            switch optionIndex {
            case 0: return 2
            case 1: return 3
            case 2: return 3
            default: return 0
            }
        })
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            poll: poll
        )
        
        // When
        let viewModel = PollAttachmentViewModel(message: message, poll: poll)
        
        // Then
        XCTAssertEqual(false, viewModel.hasMostVotes(for: poll.options[0]))
        XCTAssertEqual(false, viewModel.hasMostVotes(for: poll.options[1]))
        XCTAssertEqual(false, viewModel.hasMostVotes(for: poll.options[2]))
    }
}
