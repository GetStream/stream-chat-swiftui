//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import SwiftUI
import XCTest

@MainActor class MentionsCommandHandler_Tests: StreamChatTestCase {
    // MARK: - canHandleCommand

    func test_canHandleCommand_whenMentionTyped_returnsCommand() {
        // Given
        let handler = makeHandler()

        // When
        let command = handler.canHandleCommand(in: "Hey @ad", caretLocation: 7)

        // Then
        XCTAssertNotNil(command)
        XCTAssertEqual(command?.id, "mentions")
        XCTAssertEqual(command?.typingSuggestion.text, "ad")
    }

    func test_canHandleCommand_whenNoMention_returnsNil() {
        // Given
        let handler = makeHandler()

        // When
        let command = handler.canHandleCommand(in: "Hey there", caretLocation: 9)

        // Then
        XCTAssertNil(command)
    }

    // MARK: - commandHandler

    func test_commandHandler_whenMatchingId_returnsSelf() {
        // Given
        let handler = makeHandler()
        let command = mentionsCommand(text: "ad")

        // When
        let result = handler.commandHandler(for: command)

        // Then
        XCTAssertTrue((result as? MentionsCommandHandler) === handler)
    }

    func test_commandHandler_whenDifferentId_returnsNil() {
        // Given
        let handler = makeHandler()
        let command = ComposerCommand(
            id: "giphy",
            typingSuggestion: TypingSuggestion(text: "", locationRange: NSRange(location: 0, length: 0)),
            displayInfo: nil
        )

        // When
        let result = handler.commandHandler(for: command)

        // Then
        XCTAssertNil(result)
    }

    // MARK: - handleCommand

    func test_handleCommand_withChatUser_replacesTextAndClearsCommand() {
        // Given
        let handler = makeHandler()
        let text = Box("@ad")
        let caret = Box(3)
        let command = Box<ComposerCommand?>(mentionsCommand(text: "ad", range: NSRange(location: 1, length: 2)))
        let user = ChatUser.mock(id: .unique, name: "admin")

        // When
        handler.handleCommand(
            for: text.binding,
            selectedRangeLocation: caret.binding,
            command: command.binding,
            extraData: ["chatUser": user]
        )

        // Then
        XCTAssertEqual(text.value, "@admin")
        XCTAssertEqual(caret.value, 6)
        XCTAssertNil(command.value)
    }

    func test_handleCommand_withUserSuggestion_replacesText() {
        // Given
        let handler = makeHandler()
        let text = Box("@ad")
        let caret = Box(3)
        let command = Box<ComposerCommand?>(mentionsCommand(text: "ad", range: NSRange(location: 1, length: 2)))
        let suggestion = MentionSuggestion.user(.mock(id: .unique, name: "admin"))

        // When
        handler.handleCommand(
            for: text.binding,
            selectedRangeLocation: caret.binding,
            command: command.binding,
            extraData: ["mentionSuggestion": suggestion]
        )

        // Then
        XCTAssertEqual(text.value, "@admin")
        XCTAssertNil(command.value)
    }

    func test_handleCommand_withRoleSuggestion_replacesText() {
        // Given
        let handler = makeHandler()
        let text = Box("@mo")
        let caret = Box(3)
        let command = Box<ComposerCommand?>(mentionsCommand(text: "mo", range: NSRange(location: 1, length: 2)))
        let suggestion = MentionSuggestion.role(Role(name: "moderator"))

        // When
        handler.handleCommand(
            for: text.binding,
            selectedRangeLocation: caret.binding,
            command: command.binding,
            extraData: ["mentionSuggestion": suggestion]
        )

        // Then
        XCTAssertEqual(text.value, "@moderator")
        XCTAssertNil(command.value)
    }

    func test_handleCommand_withHereSuggestion_replacesText() {
        // Given
        let handler = makeHandler()
        let text = Box("@he")
        let caret = Box(3)
        let command = Box<ComposerCommand?>(mentionsCommand(text: "he", range: NSRange(location: 1, length: 2)))

        // When
        handler.handleCommand(
            for: text.binding,
            selectedRangeLocation: caret.binding,
            command: command.binding,
            extraData: ["mentionSuggestion": MentionSuggestion.here]
        )

        // Then
        XCTAssertEqual(text.value, "@here")
        XCTAssertNil(command.value)
    }

    func test_handleCommand_withoutMentionData_doesNotChangeText() {
        // Given
        let handler = makeHandler()
        let text = Box("@ad")
        let caret = Box(3)
        let command = Box<ComposerCommand?>(mentionsCommand(text: "ad", range: NSRange(location: 1, length: 2)))

        // When
        handler.handleCommand(
            for: text.binding,
            selectedRangeLocation: caret.binding,
            command: command.binding,
            extraData: [:]
        )

        // Then
        XCTAssertEqual(text.value, "@ad")
        XCTAssertNotNil(command.value)
    }

    func test_handleCommand_withoutCommand_doesNothing() {
        // Given
        let handler = makeHandler()
        let text = Box("@ad")
        let caret = Box(3)
        let command = Box<ComposerCommand?>(nil)

        // When
        handler.handleCommand(
            for: text.binding,
            selectedRangeLocation: caret.binding,
            command: command.binding,
            extraData: ["chatUser": ChatUser.mock(id: .unique, name: "admin")]
        )

        // Then
        XCTAssertEqual(text.value, "@ad")
    }

    // MARK: - showSuggestions

    func test_showSuggestions_withCustomProvider_returnsProviderSuggestions() async {
        // Given
        let provider = MockMentionSuggestionsProvider(suggestions: [
            .user(.mock(id: .unique, name: "Martin")),
            .here,
            .channel,
            .role(Role(name: "admin")),
            .group(makeGroup(name: "Dream Team"))
        ])
        let handler = makeHandler(provider: provider)
        let expectation = expectation(description: "suggestions")

        // When
        let cancellable = handler.showSuggestions(for: mentionsCommand(text: "")).sink { _ in
        } receiveValue: { info in
            // Then
            XCTAssertEqual(info.key, "mentions")
            let suggestions = info.value as? [MentionSuggestion]
            XCTAssertEqual(suggestions?.map(\.type), [.user, .here, .channel, .role, .group])
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: defaultTimeout)
        cancellable.cancel()
    }

    func test_showSuggestions_forwardsRequestToProvider() async {
        // Given
        let provider = MockMentionSuggestionsProvider(suggestions: [])
        let handler = makeHandler(provider: provider)
        let expectation = expectation(description: "suggestions")

        // When
        let cancellable = handler.showSuggestions(for: mentionsCommand(text: "mar")).sink { _ in
        } receiveValue: { _ in
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: defaultTimeout)
        cancellable.cancel()

        // Then
        XCTAssertEqual(provider.receivedRequests.map(\.text), ["mar"])
    }

    func test_showSuggestions_whenProviderThrows_returnsEmpty() async {
        // Given
        let provider = MockMentionSuggestionsProvider(error: ClientError("error"))
        let handler = makeHandler(provider: provider)
        let expectation = expectation(description: "suggestions")

        // When
        let cancellable = handler.showSuggestions(for: mentionsCommand(text: "mar")).sink { _ in
        } receiveValue: { info in
            // Then
            let suggestions = info.value as? [MentionSuggestion]
            XCTAssertEqual(suggestions?.isEmpty, true)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: defaultTimeout)
        cancellable.cancel()
    }

    func test_showSuggestions_whenNoChannel_returnsEmpty() async {
        // Given
        let provider = MockMentionSuggestionsProvider(suggestions: [.here])
        let channelController = ChatChannelController_Mock.mock(client: chatClient)
        let handler = MentionsCommandHandler(
            channelController: channelController,
            commandSymbol: "@",
            provider: provider
        )
        let expectation = expectation(description: "suggestions")

        // When
        let cancellable = handler.showSuggestions(for: mentionsCommand(text: "")).sink { _ in
        } receiveValue: { info in
            // Then
            let suggestions = info.value as? [MentionSuggestion]
            XCTAssertEqual(suggestions?.isEmpty, true)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: defaultTimeout)
        cancellable.cancel()

        // Then
        XCTAssertTrue(provider.receivedRequests.isEmpty)
    }

    // MARK: - private

    private func makeHandler(provider: MentionSuggestionsProvider? = nil) -> MentionsCommandHandler {
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        return MentionsCommandHandler(
            channelController: channelController,
            commandSymbol: "@",
            provider: provider
        )
    }

    private func mentionsCommand(
        text: String,
        range: NSRange = NSRange(location: 1, length: 0)
    ) -> ComposerCommand {
        ComposerCommand(
            id: "mentions",
            typingSuggestion: TypingSuggestion(text: text, locationRange: range),
            displayInfo: nil
        )
    }

    private func makeGroup(name: String) -> UserGroup {
        UserGroup(id: .unique, name: name, createdAt: .init(), updatedAt: .init())
    }
}

/// A mutable reference box that exposes a SwiftUI `Binding` for tests.
private final class Box<Value> {
    var value: Value
    init(_ value: Value) { self.value = value }
    var binding: Binding<Value> {
        Binding(get: { self.value }, set: { self.value = $0 })
    }
}

private final class MockMentionSuggestionsProvider: MentionSuggestionsProvider, @unchecked Sendable {
    let suggestions: [MentionSuggestion]
    let error: Error?
    private(set) var receivedRequests: [MentionSuggestionsRequest] = []

    init(suggestions: [MentionSuggestion] = [], error: Error? = nil) {
        self.suggestions = suggestions
        self.error = error
    }

    func mentionSuggestions(for request: MentionSuggestionsRequest) async throws -> [MentionSuggestion] {
        receivedRequests.append(request)
        if let error {
            throw error
        }
        return suggestions
    }
}
