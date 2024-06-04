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
    
    func test_canShowDiscardConfirmation_whenQuestionOnlyWhitespace() {
        // Given
        // When
        let viewModel = CreatePollViewModel(chatController: chatClient.channelController(for: .unique), messageController: nil)
        viewModel.question = "              "
        
        // Then
        XCTAssertEqual(viewModel.canShowDiscardConfirmation, false)
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
    
    // MARK: - Computed variables
    
    func test_multipleAnswersShown_defaultConfig() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertTrue(viewModel.multipleAnswersShown)
        XCTAssertFalse(viewModel.multipleAnswers)
    }
    
    func test_multipleAnswersShown_hidden() {
        let utils = Utils(
            pollsConfig: .init(multipleAnswers: .init(configurable: false, defaultValue: false))
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertFalse(viewModel.multipleAnswersShown)
        XCTAssertFalse(viewModel.multipleAnswers)
    }
    
    func test_anonymousPollShown_defaultConfig() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertTrue(viewModel.anonymousPollShown)
        XCTAssertFalse(viewModel.anonymousPoll)
    }
    
    func test_anonymousPollShown_hidden() {
        let utils = Utils(
            pollsConfig: .init(anonymousPoll: .init(configurable: false, defaultValue: false))
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertFalse(viewModel.anonymousPollShown)
        XCTAssertFalse(viewModel.anonymousPoll)
    }
    
    func test_suggestAnOptionShown_defaultConfig() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertTrue(viewModel.suggestAnOptionShown)
        XCTAssertFalse(viewModel.suggestAnOption)
    }
    
    func test_suggestAnOptionShown_hidden() {
        let utils = Utils(
            pollsConfig: .init(suggestAnOption: .init(configurable: false, defaultValue: false))
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertFalse(viewModel.suggestAnOptionShown)
        XCTAssertFalse(viewModel.suggestAnOption)
    }
    
    func test_addCommentsShown_defaultConfig() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertTrue(viewModel.addCommentsShown)
        XCTAssertFalse(viewModel.allowComments)
    }
    
    func test_addCommentsShown_hidden() {
        let utils = Utils(
            pollsConfig: .init(addComments: .init(configurable: false, defaultValue: false))
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertFalse(viewModel.addCommentsShown)
        XCTAssertFalse(viewModel.allowComments)
    }
    
    func test_maxVotesShown_defaultConfig() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertTrue(viewModel.maxVotesShown)
        XCTAssertFalse(viewModel.maxVotesEnabled)
    }
    
    func test_maxVotesShown_hidden() {
        let utils = Utils(
            pollsConfig: .init(maxVotesPerPerson: .init(configurable: false, defaultValue: false))
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        XCTAssertFalse(viewModel.maxVotesShown)
        XCTAssertFalse(viewModel.maxVotesEnabled)
    }
    
    // MARK: - Input Errors
    
    func test_optionsErrorIndices_ignoreWhitespaceAndCase() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        viewModel.options = ["   123ab   "]
        viewModel.options.append("123Ab")
        viewModel.options.append("123AB ")
        XCTAssertEqual(Set([1, 2]), viewModel.optionsErrorIndices)
    }
    
    func test_showsMaxVotesError_whenMaxVotesEnabledAndInvalidValue_thenShown() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        viewModel.maxVotesEnabled = true
        viewModel.maxVotes = "11"
        XCTAssertEqual(true, viewModel.showsMaxVotesError)
    }
    
    func test_showsMaxVotesError_whenMaxVotesDisabledAndInvalidValue_thenHidden() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        viewModel.maxVotesEnabled = false
        viewModel.maxVotes = "11"
        XCTAssertEqual(false, viewModel.showsMaxVotesError)
    }
    
    func test_showsMaxVotesError_whenMaxVotesEnabledAndValidValue_thenHidden() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        viewModel.maxVotesEnabled = false
        viewModel.maxVotes = "10"
        XCTAssertEqual(false, viewModel.showsMaxVotesError)
    }
    
    func test_showsMaxVotesError_whenMaxVotesEnabledAndInvalidZeroValue_thenShown() {
        let viewModel = CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
        viewModel.maxVotesEnabled = true
        viewModel.maxVotes = "0"
        XCTAssertEqual(true, viewModel.showsMaxVotesError)
    }
}
