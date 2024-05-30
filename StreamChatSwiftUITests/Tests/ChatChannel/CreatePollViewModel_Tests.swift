//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

final class CreatePollViewModel_Tests: StreamChatTestCase {
    
    // MARK: - Can Show Discard Confirmation
    
    func test_canShowDiscardConfirmation_whenEmpty() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique), messageController: nil)
        
        // Then
        XCTAssertEqual(viewModel.canShowDiscardConfirmation, false)
    }
    
    func test_canShowDiscardConfirmation_whenToggleChangesButNoTextEntry() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique), messageController: nil)
        viewModel.allowComments.toggle()
        
        // Then
        XCTAssertEqual(viewModel.canShowDiscardConfirmation, false)
    }
    
    func test_canShowDiscardConfirmation_whenQuestionFilled() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique), messageController: nil)
        viewModel.question = "A"
        
        // Then
        XCTAssertEqual(viewModel.canShowDiscardConfirmation, true)
    }
    
    func test_canShowDiscardConfirmation_whenOptionAdded() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique), messageController: nil)
        viewModel.options = ["A"]
        
        // Then
        XCTAssertEqual(viewModel.canShowDiscardConfirmation, true)
    }
    
    // MARK: - Can Create Poll
    
    func test_canCreatePoll_whenRequiredInformationAdded() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique), messageController: nil)
        viewModel.question = " A  "
        viewModel.options = ["O     "]
        
        // Then
        XCTAssertEqual(viewModel.canCreatePoll, true)
    }
    
    func test_canCreatePoll_whenEmptyOrChangedToggles() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique), messageController: nil)
        viewModel.allowComments.toggle()
        
        // Then
        XCTAssertEqual(viewModel.canCreatePoll, false)
    }
    
    func test_canCreatePoll_whenInsertingInformation() {
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique), messageController: nil)
        XCTAssertEqual(viewModel.canCreatePoll, false)
        viewModel.question = "A"
        XCTAssertEqual(viewModel.canCreatePoll, false)
        viewModel.options = ["A", "a"] // duplicate error
        XCTAssertEqual(viewModel.canCreatePoll, false)
        viewModel.options = ["A", "aa"]
        XCTAssertEqual(viewModel.canCreatePoll, true)
    }
}
