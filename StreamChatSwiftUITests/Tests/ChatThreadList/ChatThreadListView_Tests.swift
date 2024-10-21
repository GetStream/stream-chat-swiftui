//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class ChatThreadListView_Tests: StreamChatTestCase {

    func test_chatThreadListView_empty() {
        let view = makeView(.empty())
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatThreadListView_loading() {
        let view = makeView(.loading())
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatThreadListView_withThreads() {
        let view = makeView(.withThreads())
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatThreadListView_loadingMoreThreads() {
        let view = makeView(.loadingMoreThreads())
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatThreadListView_reloadingThreads() {
        let view = makeView(.reloadingThreads())
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatThreadListView_whenNewThreadsAvailable() {
        let view = makeView(.newThreadsAvailable())
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatThreadListView_errorLoadingThreads() {
        let view = makeView(.errorLoadingThreads())
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatThreadListView_errorLoadingMoreThreads() {
        let view = makeView(.errorLoadingMoreThreads())
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    private func makeView(_ viewModel: MockChatThreadListViewModel) -> some View {
        ChatThreadListView(
            viewFactory: DefaultViewFactory.shared,
            viewModel: viewModel
        )
        .applyDefaultSize()
    }
}

class CustomFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient

    func makeThreadListLoadingView() -> some View {
        LoadingView()
    }
}

private class MockChatThreadListViewModel: ChatThreadListViewModel {
    static func empty() -> MockChatThreadListViewModel {
        MockChatThreadListViewModel(
            threads: [],
            isLoading: false,
            isReloading: false,
            isEmpty: true,
            failedToLoadThreads: false,
            failedToLoadMoreThreads: false,
            isLoadingMoreThreads: false,
            hasLoadedAllThreads: false,
            newThreadsCount: 0,
            hasNewThreads: false
        )
    }

    static func loading() -> MockChatThreadListViewModel {
        MockChatThreadListViewModel(
            threads: [],
            isLoading: true,
            isReloading: false,
            isEmpty: false,
            failedToLoadThreads: false,
            failedToLoadMoreThreads: false,
            isLoadingMoreThreads: false,
            hasLoadedAllThreads: false,
            newThreadsCount: 0,
            hasNewThreads: false
        )
    }

    static func withThreads() -> MockChatThreadListViewModel {
        MockChatThreadListViewModel(
            threads: mockThreads,
            isLoading: false,
            isReloading: false,
            isEmpty: false,
            failedToLoadThreads: false,
            failedToLoadMoreThreads: false,
            isLoadingMoreThreads: false,
            hasLoadedAllThreads: false,
            newThreadsCount: 0,
            hasNewThreads: false
        )
    }

    static func loadingMoreThreads() -> MockChatThreadListViewModel {
        MockChatThreadListViewModel(
            threads: mockThreads,
            isLoading: false,
            isReloading: false,
            isEmpty: false,
            failedToLoadThreads: false,
            failedToLoadMoreThreads: false,
            isLoadingMoreThreads: true,
            hasLoadedAllThreads: false,
            newThreadsCount: 0,
            hasNewThreads: false
        )
    }

    static func reloadingThreads() -> MockChatThreadListViewModel {
        MockChatThreadListViewModel(
            threads: mockThreads,
            isLoading: false,
            isReloading: true,
            isEmpty: false,
            failedToLoadThreads: false,
            failedToLoadMoreThreads: false,
            isLoadingMoreThreads: false,
            hasLoadedAllThreads: false,
            newThreadsCount: 0,
            hasNewThreads: false
        )
    }

    static func newThreadsAvailable() -> MockChatThreadListViewModel {
        MockChatThreadListViewModel(
            threads: mockThreads,
            isLoading: false,
            isReloading: false,
            isEmpty: false,
            failedToLoadThreads: false,
            failedToLoadMoreThreads: false,
            isLoadingMoreThreads: false,
            hasLoadedAllThreads: false,
            newThreadsCount: 2,
            hasNewThreads: true
        )
    }

    static func errorLoadingThreads() -> MockChatThreadListViewModel {
        MockChatThreadListViewModel(
            threads: [],
            isLoading: false,
            isReloading: false,
            isEmpty: true,
            failedToLoadThreads: true,
            failedToLoadMoreThreads: false,
            isLoadingMoreThreads: false,
            hasLoadedAllThreads: false,
            newThreadsCount: 0,
            hasNewThreads: false
        )
    }

    static func errorLoadingMoreThreads() -> MockChatThreadListViewModel {
        MockChatThreadListViewModel(
            threads: mockThreads,
            isLoading: false,
            isReloading: false,
            isEmpty: false,
            failedToLoadThreads: false,
            failedToLoadMoreThreads: true,
            isLoadingMoreThreads: false,
            hasLoadedAllThreads: false,
            newThreadsCount: 0,
            hasNewThreads: false
        )
    }

    convenience init(
        threads: [ChatThread],
        isLoading: Bool,
        isReloading: Bool,
        isEmpty: Bool,
        failedToLoadThreads: Bool,
        failedToLoadMoreThreads: Bool,
        isLoadingMoreThreads: Bool,
        hasLoadedAllThreads: Bool,
        newThreadsCount: Int,
        hasNewThreads: Bool
    ) {
        self.init(threadListController: nil, eventsController: nil)
        self.threads = LazyCachedMapCollection(elements: threads)
        self.isLoading = isLoading
        self.isReloading = isReloading
        self.isEmpty = isEmpty
        self.failedToLoadThreads = failedToLoadThreads
        self.failedToLoadMoreThreads = failedToLoadMoreThreads
        self.isLoadingMoreThreads = isLoadingMoreThreads
        self.hasLoadedAllThreads = hasLoadedAllThreads
        self.newThreadsCount = newThreadsCount
        self.hasNewThreads = hasNewThreads
    }

    override func viewDidAppear() {}
    override func loadThreads() {}
    override func loadMoreThreads() {}
    override func controller(
        _ controller: ChatThreadListController,
        didChangeThreads changes: [ListChange<ChatThread>]
    ) {}
    
    static var mockYoda = ChatUser.mock(id: .unique, name: "Yoda")
    static var mockVader = ChatUser.mock(id: .unique, name: "Vader")

    static var mockThreads: [ChatThread] {
        [
            .mock(
                parentMessage: .mock(text: "Parent Message", author: mockYoda),
                channel: .mock(cid: .unique, name: "Star Wars Channel"),
                createdBy: mockVader,
                replyCount: 3,
                participantCount: 2,
                threadParticipants: [
                    .mock(user: mockYoda),
                    .mock(user: mockVader)
                ],
                lastMessageAt: .unique,
                createdAt: .unique,
                updatedAt: .unique,
                title: nil,
                latestReplies: [
                    .mock(text: "First Message", author: mockYoda),
                    .mock(text: "Second Message", author: mockVader),
                    .mock(text: "Third Message", author: mockYoda)
                ],
                reads: [
                    .mock(user: mockYoda, unreadMessagesCount: 6)
                ],
                extraData: [:]
            ),
            .mock(
                parentMessage: .mock(text: "Parent Message 2", author: mockYoda),
                channel: .mock(cid: .unique, name: "Marvel Channel"),
                createdBy: mockVader,
                replyCount: 3,
                participantCount: 2,
                threadParticipants: [
                    .mock(user: mockYoda),
                    .mock(user: mockVader)
                ],
                lastMessageAt: .unique,
                createdAt: .unique,
                updatedAt: .unique,
                title: nil,
                latestReplies: [
                    .mock(text: "First Message", author: mockVader)
                ],
                reads: [],
                extraData: [:]
            )
        ]
    }
}
