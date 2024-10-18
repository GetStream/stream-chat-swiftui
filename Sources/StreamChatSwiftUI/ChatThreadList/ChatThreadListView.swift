//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat thread list.
public struct ChatThreadListView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    @StateObject private var viewModel: ChatThreadListViewModel

    private let viewFactory: Factory
    private let title: String
    private var embedInNavigationView: Bool

    /// Creates a thread list view.
    ///
    /// - Parameters:
    ///   - viewFactory: The view factory used for creating views used by the thread list.
    ///   - viewModel: The view model instance providing the data. Default view model is created if nil.
    ///   - threadListController: The thread list controller managing the list of threads used as a data source for the view model. Default controller is created if nil.
    ///   - title: A custom title used as the navigation bar title.
    ///   - embedInNavigationView: True, if the thread list view should be embedded in a navigation stack.
    ///
    /// Changing the instance of the passed in `viewModel` or `threadListController` does not have an effect without reloading the thread list view by assigning a custom identity. The custom identity should be refreshed when either of the passed in instances have been recreated.
    /// ```swift
    /// ChatThreadListView(
    ///   viewModel: viewModel
    /// )
    /// .id(myCustomViewIdentity)
    /// ```
    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        viewModel: ChatThreadListViewModel? = nil,
        threadListController: ChatThreadListController? = nil,
        title: String? = nil,
        embedInNavigationView: Bool = true
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeThreadListViewModel(
                threadListController: threadListController
            )
        )
        self.viewFactory = viewFactory
        self.title = title ?? L10n.Thread.title
        self.embedInNavigationView = embedInNavigationView
    }

    public var body: some View {
        NavigationContainerView(embedInNavigationView: embedInNavigationView) {
            Group {
                if viewModel.isLoading {
                    viewFactory.makeThreadListLoadingView()
                } else if viewModel.isEmpty {
                    viewFactory.makeNoThreadsView()
                } else {
                    ChatThreadListContentView(
                        viewFactory: viewFactory,
                        viewModel: viewModel
                    )
                }
            }
            .bottomBanner(isPresented: viewModel.failedToLoadThreads || viewModel.failedToLoadMoreThreads) {
                viewFactory.makeThreadsListErrorBannerView {
                    viewModel.retryLoadThreads()
                }
            }
            .accentColor(colors.tintColor)
            .background(
                viewFactory.makeThreadListBackground(colors: colors)
            )
            .modifier(viewFactory.makeThreadListHeaderViewModifier(title: title))
            .modifier(viewFactory.makeThreadListContainerViewModifier(viewModel: viewModel))
            .onAppear {
                viewModel.viewDidAppear()
            }
        }
    }
}

extension ChatThreadListView where Factory == DefaultViewFactory {
    public init() {
        self.init(viewFactory: DefaultViewFactory.shared)
    }
}

public struct ChatThreadListContentView<Factory: ViewFactory>: View {
    private var viewFactory: Factory
    @ObservedObject private var viewModel: ChatThreadListViewModel

    public init(
        viewFactory: Factory,
        viewModel: ChatThreadListViewModel
    ) {
        self.viewFactory = viewFactory
        self.viewModel = viewModel
    }

    public var body: some View {
        ThreadList(
            factory: viewFactory,
            threads: viewModel.threads,
            threadDestination: viewFactory.makeThreadDestination(),
            selectedThread: $viewModel.selectedThread,
            onItemTap: { thread in
                viewModel.selectedThread = .init(thread: thread)
            },
            onItemAppear: { index in
                viewModel.didAppearThread(at: index)
            },
            headerView: {
                viewFactory.makeThreadListHeaderView(viewModel: viewModel)
            },
            footerView: {
                viewFactory.makeThreadListFooterView(viewModel: viewModel)
            }
        )
    }
}
