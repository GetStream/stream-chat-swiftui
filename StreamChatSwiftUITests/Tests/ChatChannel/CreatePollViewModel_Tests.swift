//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

final class CreatePollViewModel_Tests: StreamChatTestCase {
    func test_canShowDiscardConfirmation_whenEmpty() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique))
        
        // Then
        XCTAssertEqual(viewModel.canShowDiscardConfirmation, false)
    }
    
    func test_canShowDiscardConfirmation_whenToggleChangesButNoTextEntry() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique))
        viewModel.allowComments.toggle()
        
        // Then
        XCTAssertEqual(viewModel.canShowDiscardConfirmation, false)
    }
    
    func test_canShowDiscardConfirmation_whenQuestionFilled() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique))
        viewModel.question = "A"
        
        // Then
        XCTAssertEqual(viewModel.canShowDiscardConfirmation, true)
    }
    
    func test_canShowDiscardConfirmation_whenOptionAdded() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique))
        viewModel.options = ["A"]
        
        // Then
        XCTAssertEqual(viewModel.canShowDiscardConfirmation, true)
    }
}
