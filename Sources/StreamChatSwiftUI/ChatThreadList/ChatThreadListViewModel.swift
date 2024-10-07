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

    /// A boolean value indicating if the view is currently loading more threads.
    public private(set) var loadingMoreThreads: Bool = false

    /// The list of threads.
    @Published public var threads = LazyCachedMapCollection<ChatThread>()

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

    public func loadThreads() {
        controller?.delegate = self
        controller?.synchronize()
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
