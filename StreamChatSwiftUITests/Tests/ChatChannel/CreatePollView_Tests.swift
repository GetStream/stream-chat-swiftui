//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class CreatePollView_Tests: StreamChatTestCase {
    // MARK: - Empty State

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

    // MARK: - Filled State

    func test_createPollView_filledQuestionAndOptionsSnapshot() {
        let view = makeCreatePollView(
            question: "What's your favorite color?",
            options: ["Red", "Blue", "Green", ""]
        ).applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_createPollView_duplicateOptionsSnapshot() {
        let view = makeCreatePollView(
            question: "Pick a number",
            options: ["One", "Two", "One", ""]
        ).applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_createPollView_manyOptionsSnapshot() {
        let view = makeCreatePollView(
            question: "Best programming language?",
            options: ["Swift", "Kotlin", "TypeScript", "Rust", "Go", ""]
        ).applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - RTL

    func test_createPollView_rightToLeft_snapshot() {
        let enabled = PollsEntryConfig(configurable: true, defaultValue: true)
        streamChat?.utils.pollsConfig = PollsConfig(
            multipleAnswers: enabled,
            anonymousPoll: enabled,
            suggestAnOption: enabled,
            addComments: enabled,
            maxVotesPerPerson: enabled
        )
        let view = makeCreatePollView().applyDefaultSize()
        AssertSnapshot(view, variants: [.rightToLeftLayout])
    }

    func test_createPollView_filledOptionsRightToLeft_snapshot() {
        let view = makeCreatePollView(
            question: "What is your favourite city?",
            options: ["Barcelona", "Lisbon", "Amsterdam", ""]
        ).applyDefaultSize()
        AssertSnapshot(view, variants: [.rightToLeftLayout])
    }

    func test_createPollView_duplicateOptionsRightToLeft_snapshot() {
        let view = makeCreatePollView(
            question: "Pick a number",
            options: ["One", "Two", "One", ""]
        ).applyDefaultSize()
        AssertSnapshot(view, variants: [.rightToLeftLayout])
    }

    // MARK: - Helpers

    private func makeCreatePollView() -> CreatePollView<DefaultTestViewFactory> {
        CreatePollView(
            factory: DefaultTestViewFactory.shared,
            chatController: .init(channelQuery: .init(cid: .unique), channelListQuery: nil, client: chatClient),
            messageController: nil
        )
    }

    private func makeCreatePollView(
        question: String,
        options: [String]
    ) -> CreatePollView<DefaultTestViewFactory> {
        let viewModel = CreatePollViewModel(
            chatController: .init(channelQuery: .init(cid: .unique), channelListQuery: nil, client: chatClient),
            messageController: nil
        )
        viewModel.question = question
        viewModel.replaceAllOptions(options)
        return CreatePollView(factory: DefaultTestViewFactory.shared, viewModel: viewModel)
    }
}
