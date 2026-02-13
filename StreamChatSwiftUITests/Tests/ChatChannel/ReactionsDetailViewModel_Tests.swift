//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor final class ReactionsDetailViewModel_Tests: StreamChatTestCase {
    // MARK: - Init

    func test_init_thenSynchronizeCalled() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)

        // When
        _ = ReactionsDetailViewModel(message: message, reactionListController: controller)

        // Then
        XCTAssertTrue(controller.synchronize_called)
    }

    func test_init_thenDelegateSet() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)

        // When
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        // Then
        XCTAssertTrue(controller.delegate === viewModel)
    }

    // MARK: - Reactions

    func test_controllerDidChangeReactions_thenReactionsUpdated() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        // When
        let reactions = makeReactions(count: 5)
        controller.reactions_simulated = reactions
        viewModel.controller(controller, didChangeReactions: [])

        // Then
        XCTAssertEqual(viewModel.reactions.count, 5)
    }

    // MARK: - Filtered Reactions

    func test_filteredReactions_whenNoFilter_thenReturnsAll() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)
        let reactions = makeReactions(count: 3)
        controller.reactions_simulated = reactions
        viewModel.controller(controller, didChangeReactions: [])

        // When
        viewModel.selectedReactionType = nil

        // Then
        XCTAssertEqual(viewModel.filteredReactions.count, 3)
    }

    func test_filteredReactions_whenFilterSet_thenReturnsFiltered() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        let like = MessageReactionType(rawValue: "like")
        let love = MessageReactionType(rawValue: "love")
        let reactions = [
            ChatMessageReaction.mock(type: like, author: .mock(id: "user1")),
            ChatMessageReaction.mock(type: like, author: .mock(id: "user2")),
            ChatMessageReaction.mock(type: love, author: .mock(id: "user3"))
        ]
        controller.reactions_simulated = reactions
        viewModel.controller(controller, didChangeReactions: [])

        // When
        viewModel.selectedReactionType = like

        // Then
        XCTAssertEqual(viewModel.filteredReactions.count, 2)
        XCTAssertTrue(viewModel.filteredReactions.allSatisfy { $0.type == like })
    }

    // MARK: - Reaction Types

    func test_reactionTypes_returnsTypesWithPositiveScores() {
        // Given
        let like = MessageReactionType(rawValue: "like")
        let love = MessageReactionType(rawValue: "love")
        let message = ChatMessage.mock(
            reactionScores: [like: 3, love: 2]
        )
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        // Then
        XCTAssertEqual(viewModel.reactionTypes.count, 2)
        XCTAssertTrue(viewModel.reactionTypes.contains(like))
        XCTAssertTrue(viewModel.reactionTypes.contains(love))
    }

    func test_reactionTypes_excludesZeroScores() {
        // Given
        let like = MessageReactionType(rawValue: "like")
        let love = MessageReactionType(rawValue: "love")
        let message = ChatMessage.mock(
            reactionScores: [like: 3, love: 0]
        )
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        // Then
        XCTAssertEqual(viewModel.reactionTypes.count, 1)
        XCTAssertTrue(viewModel.reactionTypes.contains(like))
    }

    // MARK: - Reaction Count

    func test_reactionCount_returnsCorrectScore() {
        // Given
        let like = MessageReactionType(rawValue: "like")
        let message = ChatMessage.mock(reactionScores: [like: 5])
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        // Then
        XCTAssertEqual(viewModel.reactionCount(for: like), 5)
    }

    func test_reactionCount_returnsZeroForUnknownType() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        // Then
        let unknown = MessageReactionType(rawValue: "unknown")
        XCTAssertEqual(viewModel.reactionCount(for: unknown), 0)
    }

    // MARK: - Author Name

    func test_authorName_whenCurrentUser_returnsCurrentUserLabel() {
        // Given
        let currentUserId = StreamChatTestCase.currentUserId
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        let reaction = ChatMessageReaction.mock(
            type: MessageReactionType(rawValue: "like"),
            author: .mock(id: currentUserId)
        )

        // Then
        XCTAssertEqual(viewModel.authorName(for: reaction), L10n.Message.Reactions.currentUser)
    }

    func test_authorName_whenOtherUser_returnsName() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        let reaction = ChatMessageReaction.mock(
            type: MessageReactionType(rawValue: "like"),
            author: .mock(id: "other_user", name: "John")
        )

        // Then
        XCTAssertEqual(viewModel.authorName(for: reaction), "John")
    }

    func test_authorName_whenOtherUserNoName_returnsId() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        let reaction = ChatMessageReaction.mock(
            type: MessageReactionType(rawValue: "like"),
            author: .mock(id: "other_user")
        )

        // Then
        XCTAssertEqual(viewModel.authorName(for: reaction), "other_user")
    }

    // MARK: - Is Current User

    func test_isCurrentUser_whenCurrentUser_returnsTrue() {
        // Given
        let currentUserId = StreamChatTestCase.currentUserId
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        let reaction = ChatMessageReaction.mock(
            type: MessageReactionType(rawValue: "like"),
            author: .mock(id: currentUserId)
        )

        // Then
        XCTAssertTrue(viewModel.isCurrentUser(reaction))
    }

    func test_isCurrentUser_whenOtherUser_returnsFalse() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        let reaction = ChatMessageReaction.mock(
            type: MessageReactionType(rawValue: "like"),
            author: .mock(id: "other_user")
        )

        // Then
        XCTAssertFalse(viewModel.isCurrentUser(reaction))
    }

    // MARK: - Total Reactions Count

    func test_totalReactionsCount_matchesMessage() {
        // Given
        let like = MessageReactionType(rawValue: "like")
        let love = MessageReactionType(rawValue: "love")
        let message = ChatMessage.mock(
            reactionScores: [like: 3, love: 2],
            reactionCounts: [like: 3, love: 2]
        )
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        // Then
        XCTAssertEqual(viewModel.totalReactionsCount, message.totalReactionsCount)
    }

    // MARK: - Pagination: onReactionAppear

    func test_onReactionAppear_whenInsideThresholdAndMoreThan25Reactions_thenLoadsMoreReactions() {
        // Given
        var loadMoreCalled = false
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 30)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - appear at index 21 (which is > 30 - 10 = 20)
        let reactionAtIndex21 = viewModel.filteredReactions[21]
        viewModel.onReactionAppear(reactionAtIndex21)

        // Then
        XCTAssertTrue(loadMoreCalled)
    }

    func test_onReactionAppear_whenNotInThreshold_thenDoesNotLoadMoreReactions() {
        // Given
        var loadMoreCalled = false
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 30)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - appear at index 0 (which is not > 30 - 10 = 20)
        let reactionAtIndex0 = viewModel.filteredReactions[0]
        viewModel.onReactionAppear(reactionAtIndex0)

        // Then
        XCTAssertFalse(loadMoreCalled)
        XCTAssertFalse(viewModel.loadingReactions)
    }

    func test_onReactionAppear_whenLessThan25Reactions_thenDoesNotLoadMore() {
        // Given
        var loadMoreCalled = false
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 20)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - appear at last reaction (index 19, which is > 20 - 10 = 10)
        let lastReaction = viewModel.filteredReactions[19]
        viewModel.onReactionAppear(lastReaction)

        // Then
        XCTAssertFalse(loadMoreCalled)
        XCTAssertFalse(viewModel.loadingReactions)
    }

    func test_onReactionAppear_whenReactionNotFound_thenDoesNotLoadMore() {
        // Given
        var loadMoreCalled = false
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 30)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - appear with a reaction not in the list
        let otherReaction = ChatMessageReaction.mock(
            id: "not_in_list",
            type: MessageReactionType(rawValue: "like"),
            author: .mock(id: "unknown")
        )
        viewModel.onReactionAppear(otherReaction)

        // Then
        XCTAssertFalse(loadMoreCalled)
        XCTAssertFalse(viewModel.loadingReactions)
    }

    func test_onReactionAppear_whenAlreadyLoading_thenDoesNotLoadAgain() {
        // Given
        var loadMoreCallCount = 0
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 30)
        controller.reactions_simulated = reactions
        // Do NOT call completion so loading stays true
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { _ in
                loadMoreCallCount += 1
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - first appear triggers loading
        let reactionAtIndex21 = viewModel.filteredReactions[21]
        viewModel.onReactionAppear(reactionAtIndex21)
        XCTAssertTrue(viewModel.loadingReactions)
        XCTAssertEqual(loadMoreCallCount, 1)

        // When - second appear while still loading
        let reactionAtIndex22 = viewModel.filteredReactions[22]
        viewModel.onReactionAppear(reactionAtIndex22)

        // Then - should not call load again
        XCTAssertEqual(loadMoreCallCount, 1)
    }

    // MARK: - Pagination: Load More Reactions Completion

    func test_loadMoreReactions_whenSuccess_thenStopsLoading() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 30)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When
        let reactionAtIndex21 = viewModel.filteredReactions[21]
        viewModel.onReactionAppear(reactionAtIndex21)

        // Then
        XCTAssertFalse(viewModel.loadingReactions)
    }

    func test_loadMoreReactions_whenSuccess_thenDelegateUpdatesReactions() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let initialReactions = makeReactions(count: 30)
        controller.reactions_simulated = initialReactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])
        XCTAssertEqual(viewModel.reactions.count, 30)

        // When - trigger load more, then simulate delegate callback with more data
        let reactionAtIndex21 = viewModel.filteredReactions[21]
        viewModel.onReactionAppear(reactionAtIndex21)

        let additionalReactions = makeReactions(count: 10, startIndex: 30)
        let allReactions = initialReactions + additionalReactions
        controller.reactions_simulated = allReactions
        viewModel.controller(controller, didChangeReactions: [])

        // Then
        XCTAssertEqual(viewModel.reactions.count, 40)
        XCTAssertFalse(viewModel.loadingReactions)
    }

    func test_loadMoreReactions_whenError_thenStopsLoading() {
        // Given
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 30)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                completion(ClientError("ERROR"))
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When
        let reactionAtIndex21 = viewModel.filteredReactions[21]
        viewModel.onReactionAppear(reactionAtIndex21)

        // Then
        XCTAssertFalse(viewModel.loadingReactions)
    }

    func test_loadMoreReactions_afterCompletion_canLoadAgain() {
        // Given
        var loadMoreCallCount = 0
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 30)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCallCount += 1
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - first load
        let reactionAtIndex21 = viewModel.filteredReactions[21]
        viewModel.onReactionAppear(reactionAtIndex21)
        XCTAssertFalse(viewModel.loadingReactions) // Completed
        XCTAssertEqual(loadMoreCallCount, 1)

        // When - second load after completion
        viewModel.onReactionAppear(reactionAtIndex21)

        // Then - should call load again
        XCTAssertEqual(loadMoreCallCount, 2)
    }

    // MARK: - Pagination with Filter

    func test_onReactionAppear_whenFilteredAndInsideThreshold_thenLoadsMore() {
        // Given
        var loadMoreCalled = false
        let like = MessageReactionType(rawValue: "like")
        let love = MessageReactionType(rawValue: "love")
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)

        // Create 30 reactions: 25 like + 5 love
        var reactions = (0..<25).map {
            ChatMessageReaction.mock(
                id: "like_\($0)",
                type: like,
                author: .mock(id: "user_\($0)")
            )
        }
        reactions += (0..<5).map {
            ChatMessageReaction.mock(
                id: "love_\($0)",
                type: love,
                author: .mock(id: "user_love_\($0)")
            )
        }
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - filter by "like" and appear near end
        viewModel.selectedReactionType = like
        let filteredReactions = viewModel.filteredReactions
        XCTAssertEqual(filteredReactions.count, 25)
        let nearEnd = filteredReactions[20]
        viewModel.onReactionAppear(nearEnd)

        // Then - should load more since total reactions count >= 25
        XCTAssertTrue(loadMoreCalled)
    }

    func test_onReactionAppear_whenFilteredButFewTotalReactions_thenDoesNotLoadMore() {
        // Given
        var loadMoreCalled = false
        let like = MessageReactionType(rawValue: "like")
        let love = MessageReactionType(rawValue: "love")
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)

        // Create 15 reactions: 10 like + 5 love (total < 25)
        var reactions = (0..<10).map {
            ChatMessageReaction.mock(
                id: "like_\($0)",
                type: like,
                author: .mock(id: "user_\($0)")
            )
        }
        reactions += (0..<5).map {
            ChatMessageReaction.mock(
                id: "love_\($0)",
                type: love,
                author: .mock(id: "user_love_\($0)")
            )
        }
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - filter by "like" and appear near end
        viewModel.selectedReactionType = like
        let filteredReactions = viewModel.filteredReactions
        XCTAssertEqual(filteredReactions.count, 10)
        let nearEnd = filteredReactions[9]
        viewModel.onReactionAppear(nearEnd)

        // Then - should NOT load more since total reactions count < 25
        XCTAssertFalse(loadMoreCalled)
    }

    // MARK: - Message Controller Delegate

    func test_messageControllerDidChangeMessage_thenMessageUpdated() {
        // Given
        let cid = ChannelId.unique
        let message = ChatMessage.mock(cid: cid)
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: cid,
            messageId: message.id
        )

        // When
        let updatedMessage = ChatMessage.mock(id: message.id, cid: cid, text: "Updated text")
        messageController.message_mock = updatedMessage
        viewModel.messageController(messageController, didChangeMessage: .update(updatedMessage))

        // Then
        XCTAssertEqual(viewModel.message.text, "Updated text")
    }

    func test_messageControllerDidChangeReactions_thenReactionsUpdated() {
        // Given
        let cid = ChannelId.unique
        let message = ChatMessage.mock(cid: cid)
        let controller = makeReactionListController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(message: message, reactionListController: controller)

        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: cid,
            messageId: message.id
        )

        // When
        let newReactions = makeReactions(count: 3)
        viewModel.messageController(messageController, didChangeReactions: newReactions)

        // Then
        XCTAssertEqual(viewModel.reactions.count, 3)
    }

    // MARK: - Boundary Conditions

    func test_onReactionAppear_whenExactly25Reactions_andInsideThreshold_thenLoadsMore() {
        // Given
        var loadMoreCalled = false
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 25)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - appear at index 16 (which is > 25 - 10 = 15)
        let reactionAtIndex16 = viewModel.filteredReactions[16]
        viewModel.onReactionAppear(reactionAtIndex16)

        // Then
        XCTAssertTrue(loadMoreCalled)
    }

    func test_onReactionAppear_whenExactly24Reactions_thenDoesNotLoadMore() {
        // Given
        var loadMoreCalled = false
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 24)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - appear near end
        let lastReaction = viewModel.filteredReactions[23]
        viewModel.onReactionAppear(lastReaction)

        // Then
        XCTAssertFalse(loadMoreCalled)
    }

    func test_onReactionAppear_atExactThresholdIndex_thenLoadsMore() {
        // Given
        var loadMoreCalled = false
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 30)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - appear at index 21 (which is > 30 - 10 = 20)
        let reactionAtThreshold = viewModel.filteredReactions[21]
        viewModel.onReactionAppear(reactionAtThreshold)

        // Then
        XCTAssertTrue(loadMoreCalled)
    }

    func test_onReactionAppear_justBeforeThreshold_thenDoesNotLoadMore() {
        // Given
        var loadMoreCalled = false
        let message = ChatMessage.mock()
        let controller = makeReactionListController(messageId: message.id)
        let reactions = makeReactions(count: 30)
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller,
            loadMoreReactionsAction: { completion in
                loadMoreCalled = true
                completion(nil)
            }
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When - appear at index 20 (which is NOT > 30 - 10 = 20)
        let reactionBeforeThreshold = viewModel.filteredReactions[20]
        viewModel.onReactionAppear(reactionBeforeThreshold)

        // Then
        XCTAssertFalse(loadMoreCalled)
    }

    // MARK: - Test Data

    private func makeReactionListController(messageId: MessageId) -> ChatReactionListControllerSUI_Mock {
        let query = ReactionListQuery(messageId: messageId)
        return ChatReactionListControllerSUI_Mock(query: query, client: chatClient)
    }

    private func makeReactions(count: Int, startIndex: Int = 0) -> [ChatMessageReaction] {
        (startIndex..<startIndex + count).map { index in
            ChatMessageReaction.mock(
                id: "reaction_\(index)",
                type: MessageReactionType(rawValue: "like"),
                author: .mock(id: "user_\(index)")
            )
        }
    }
}
