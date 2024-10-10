//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat

/// View model for the `ChatThreadListView`.
open class ChatThreadListViewModel: ObservableObject, ChatThreadListControllerDelegate {

    /// Context provided dependencies.
    @Injected(\.chatClient) private var chatClient: ChatClient
    @Injected(\.images) private var images: Images
    @Injected(\.utils) private var utils: Utils

    /// The controller that manages the thread list data.
    private var controller: ChatThreadListController?

    /// A boolean value indicating if the initial threads have been loaded.
    public private(set) var hasLoadedThreads = false

    /// The list of threads.
    @Published public var threads = LazyCachedMapCollection<ChatThread>()

    /// A boolean indicating if it is loading data from the server and no local cache is available.
    @Published public var isLoading = false

    /// A boolean indicating that there is no data from server.
    @Published public var isEmpty = false

    /// A boolean indicating if it failed loading the initial data from the server.
    @Published public var failedToLoadThreads = false

    /// A boolean indicating if it failed loading threads while paginating.
    @Published public var failedToLoadMoreThreads = false

    /// A boolean value indicating if the view is currently loading more threads.
    @Published public var isLoadingMoreThreads: Bool = false

    /// A boolean value indicating if all the older threads are loaded.
    @Published public var hasLoadedAllThreads: Bool = false

    /// Creates a view model for the `ChatThreadListView`.
    ///
    /// - Parameters:
    ///   - threadListController: A controller providing the list of threads. If nil, a controller with default `ThreadListQuery` is created.
    public init(
        threadListController: ChatThreadListController? = nil
    ) {
        if let threadListController = threadListController {
            self.controller = threadListController
        } else {
            makeDefaultThreadListController()
        }
    }

    public func retryLoadThreads() {
        if failedToLoadThreads {
            loadThreads()
            return
        }

        loadMoreThreads()
    }

    public func loadThreads() {
        controller?.delegate = self
        isLoading = controller?.threads.isEmpty == true
        failedToLoadThreads = false
        controller?.synchronize { [weak self] error in
            self?.isLoading = false
            self?.hasLoadedThreads = error == nil
            self?.failedToLoadThreads = error != nil
            self?.isEmpty = self?.controller?.threads.isEmpty == true
            self?.hasLoadedAllThreads = self?.controller?.hasLoadedAllThreads ?? false
        }
    }

    public func didAppearThread(at index: Int) {
        guard index >= threads.count - 5 else {
            return
        }

        loadMoreThreads()
    }

    public func loadMoreThreads() {
        if isLoadingMoreThreads || controller?.hasLoadedAllThreads == true {
            return
        }
        
        isLoadingMoreThreads = true
        controller?.loadMoreThreads { [weak self] result in
            self?.isLoadingMoreThreads = false
            self?.hasLoadedAllThreads = self?.controller?.hasLoadedAllThreads ?? false
            let threads = try? result.get()
            self?.failedToLoadMoreThreads = threads == nil
        }
    }

    public func controller(
        _ controller: ChatThreadListController,
        didChangeThreads changes: [ListChange<ChatThread>]
    ) {
        threads = controller.threads
    }

    private func makeDefaultThreadListController() {
        guard let currentUserId = chatClient.currentUserId else {
            // TODO: observeClientIdChange()
            return
        }
        controller = chatClient.threadListController(
            query: .init(watch: true)
        )
    }
}
