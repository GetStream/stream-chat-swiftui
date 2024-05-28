//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class PollAttachmentView_Tests: StreamChatTestCase {

    func test_pollAttachmentView_snapshotCommentsAndSuggestions() {
        // Given
        let poll = Poll.mock()
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            poll: poll
        )
        
        // When
        let view = PollAttachmentView(
            factory: DefaultViewFactory.shared,
            message: message,
            poll: poll,
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: 240)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_pollAttachmentView_snapshotUniqueVotes() {
        // Given
        let poll = Poll.mock(
            allowAnswers: false,
            allowUserSuggestedOptions: false,
            enforceUniqueVote: true
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            poll: poll
        )
        
        // When
        let view = PollAttachmentView(
            factory: DefaultViewFactory.shared,
            message: message,
            poll: poll,
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: 150)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_pollAttachmentView_closedPoll() {
        // Given
        let poll = Poll.mock(
            allowAnswers: false,
            allowUserSuggestedOptions: false,
            enforceUniqueVote: true,
            isClosed: true
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            poll: poll
        )
        
        // When
        let view = PollAttachmentView(
            factory: DefaultViewFactory.shared,
            message: message,
            poll: poll,
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: 150)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_pollAttachmentView_resultsSnapshot() {
        // Given
        let poll = Poll.mock()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)
        
        // When
        let view = PollResultsView(viewModel: viewModel)
            .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_pollAttachmentView_allOptions() {
        // Given
        let poll = Poll.mock()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)
        
        // When
        let view = PollAllOptionsView(viewModel: viewModel)
            .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
