//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

class ChatThreadListViewModel_Tests: StreamChatTestCase {

    func test_viewDidAppear_thenLoadsThreads() {
        let mockThreadListController = ChatThreadListController_Mock.mock(
            query: .init(watch: true)
        )
        let viewModel = ChatThreadListViewModel(
            threadListController: mockThreadListController
        )

        viewModel.viewDidAppear()
        XCTAssertEqual(mockThreadListController.synchronize_callCount, 1)
    }

    func test_viewDidAppear_whenAlreadyLoadedThreads_thenDoesNotLoadsThreads() {
        let mockThreadListController = ChatThreadListController_Mock.mock(
            query: .init(watch: true)
        )
        let viewModel = ChatThreadListViewModel(
            threadListController: mockThreadListController
        )

        viewModel.viewDidAppear()
        mockThreadListController.synchronize_completion?(nil)
        viewModel.viewDidAppear()

        XCTAssertEqual(mockThreadListController.synchronize_callCount, 1)
    }

    func test_loadThreads_whenInitialEmptyData_whenSuccess() {
        let mockThreadListController = ChatThreadListController_Mock.mock(
            query: .init(watch: true)
        )
        mockThreadListController.threads_mock = []
        let viewModel = ChatThreadListViewModel(
            threadListController: mockThreadListController
        )

        viewModel.loadThreads()

        XCTAssertEqual(viewModel.isLoading, true)
        XCTAssertEqual(viewModel.isReloading, false)
        XCTAssertEqual(viewModel.failedToLoadThreads, false)
        XCTAssertEqual(viewModel.hasLoadedThreads, false)

        mockThreadListController.threads_mock = [.mock()]
        mockThreadListController.synchronize_completion?(nil)

        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.isReloading, false)
        XCTAssertEqual(viewModel.failedToLoadThreads, false)
        XCTAssertEqual(viewModel.hasLoadedThreads, true)
        XCTAssertEqual(viewModel.isEmpty, false)
    }

    func test_loadThreads_whenCacheAvailable_whenSuccess() {
        let mockThreadListController = ChatThreadListController_Mock.mock(
            query: .init(watch: true)
        )
        mockThreadListController.threads_mock = [.mock()]
        let viewModel = ChatThreadListViewModel(
            threadListController: mockThreadListController
        )

        viewModel.loadThreads()

        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.isReloading, true)
        XCTAssertEqual(viewModel.failedToLoadThreads, false)
        XCTAssertEqual(viewModel.hasLoadedThreads, false)

        mockThreadListController.threads_mock = [.mock(), .mock()]
        mockThreadListController.synchronize_completion?(nil)

        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.isReloading, false)
        XCTAssertEqual(viewModel.failedToLoadThreads, false)
        XCTAssertEqual(viewModel.hasLoadedThreads, true)
        XCTAssertEqual(viewModel.isEmpty, false)
    }

    func test_loadThreads_whenError() {
        let mockThreadListController = ChatThreadListController_Mock.mock(
            query: .init(watch: true)
        )
        mockThreadListController.threads_mock = []
        let viewModel = ChatThreadListViewModel(
            threadListController: mockThreadListController
        )

        viewModel.loadThreads()
        mockThreadListController.threads_mock = [.mock()]
        mockThreadListController.synchronize_completion?(ClientError("ERROR"))

        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.isReloading, false)
        XCTAssertEqual(viewModel.failedToLoadThreads, true)
        XCTAssertEqual(viewModel.failedToLoadMoreThreads, false)
        XCTAssertEqual(viewModel.hasLoadedThreads, false)
    }

    func test_didAppearThread_whenInsideThreshold_thenLoadMoreThreads() {
        let mockThreadListController = ChatThreadListController_Mock.mock(
            query: .init(watch: true)
        )
        let viewModel = ChatThreadListViewModel(
            threadListController: mockThreadListController
        )
        let mockedThreads: [ChatThread] = [
            .mock(), .mock(), .mock(), .mock(), .mock(), .mock(), .mock()
        ]
        mockedThreads.forEach { thread in
            viewModel.threads.append(thread)
        }

        XCTAssertEqual(viewModel.isLoadingMoreThreads, false)

        viewModel.didAppearThread(at: 5)

        XCTAssertEqual(viewModel.isLoadingMoreThreads, true)
    }

    func test_didAppearThread_whenNotInThreshold_thenDoNotLoadMoreThreads() {
        let mockThreadListController = ChatThreadListController_Mock.mock(
            query: .init(watch: true)
        )
        let viewModel = ChatThreadListViewModel(
            threadListController: mockThreadListController
        )
        let mockedThreads: [ChatThread] = [
            .mock(), .mock(), .mock(), .mock(), .mock(), .mock(), .mock()
        ]
        mockedThreads.forEach { thread in
            viewModel.threads.append(thread)
        }

        XCTAssertEqual(viewModel.isLoadingMoreThreads, false)

        viewModel.didAppearThread(at: 0)

        XCTAssertEqual(viewModel.isLoadingMoreThreads, false)
    }

    func test_didReceiveThreadMessageNewEvent() {
        let mockThreadListController = ChatThreadListController_Mock.mock(
            query: .init(watch: true)
        )
        let viewModel = ChatThreadListViewModel(
            threadListController: mockThreadListController
        )
        let eventController = mockThreadListController.client.eventsController()

        // 2 Events
        viewModel.eventsController(
            eventController,
            didReceiveEvent: ThreadMessageNewEvent(
                message: .mock(parentMessageId: .unique),
                channel: .mock(cid: .unique),
                unreadCount: .noUnread,
                createdAt: .unique
            )
        )
        viewModel.eventsController(
            eventController,
            didReceiveEvent: ThreadMessageNewEvent(
                message: .mock(parentMessageId: .unique),
                channel: .mock(cid: .unique),
                unreadCount: .noUnread,
                createdAt: .unique
            )
        )

        XCTAssertEqual(viewModel.newThreadsCount, 2)
        XCTAssertTrue(viewModel.hasNewThreads)
    }
}
