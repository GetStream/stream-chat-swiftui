//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the list of the current user's scheduled messages.
///
/// The query of the view model's controller decides which scheduled messages are listed, for example the ones of
/// a single channel.
public struct ScheduledMessageListView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors

    @StateObject private var viewModel: ScheduledMessageListViewModel

    private let viewFactory: Factory
    private let title: String
    private let embedInNavigationView: Bool
    private let onItemTap: (@MainActor (ScheduledMessage) -> Void)?

    /// Creates a scheduled message list view.
    ///
    /// - Parameters:
    ///   - viewFactory: The view factory used for creating views used by the scheduled message list.
    ///   - viewModel: The view model providing the data. It is created once, when the view first appears.
    ///   - title: A custom title used as the navigation bar title.
    ///   - embedInNavigationView: True, if the scheduled message list view should be embedded in a navigation stack.
    ///   - onItemTap: Called when a scheduled message is tapped. It is not called for a message which is being sent
    ///   or whose attachments are uploading. Without it, the rows can't be tapped.
    ///
    /// Changing the instance of the passed in `viewModel` does not have an effect without reloading the scheduled
    /// message list view by assigning a custom identity.
    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        viewModel: @autoclosure @escaping () -> ScheduledMessageListViewModel,
        title: String? = nil,
        embedInNavigationView: Bool = true,
        onItemTap: (@MainActor (ScheduledMessage) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.viewFactory = viewFactory
        self.title = title ?? L10n.ScheduledMessages.title
        self.embedInNavigationView = embedInNavigationView
        self.onItemTap = onItemTap
    }

    public var body: some View {
        NavigationContainerView(embedInNavigationView: embedInNavigationView) {
            Group {
                switch viewModel.viewState {
                case .loading:
                    viewFactory.makeScheduledMessageListLoadingView(options: ScheduledMessageListLoadingViewOptions())
                        .modifier(searchableModifier)
                case .loaded:
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.scheduledMessages) { scheduledMessage in
                                ScheduledMessageListRowView(
                                    viewFactory: viewFactory,
                                    scheduledMessage: scheduledMessage,
                                    channel: viewModel.channels[scheduledMessage.cid],
                                    onItemTap: onItemTap
                                )
                                Divider()
                                    .overlay(Color(colors.borderCoreSubtle))
                            }
                        }
                    }
                    .modifier(searchableModifier)
                case .failed:
                    viewFactory.makeScheduledMessageListErrorView(
                        options: ScheduledMessageListErrorViewOptions(onRetry: viewModel.loadScheduledMessages)
                    )
                case .empty:
                    viewFactory.makeScheduledMessageListEmptyView(options: ScheduledMessageListEmptyViewOptions())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(colors.backgroundCoreApp).edgesIgnoringSafeArea(.bottom))
            .modifier(ChatThreadListHeaderViewModifier(title: title))
            .onAppear {
                viewModel.viewDidAppear()
            }
        }
        .accessibilityIdentifier("ScheduledMessageListView")
    }

    private var searchableModifier: some ViewModifier {
        viewFactory.styles.makeSearchableModifier(
            options: SearchableModifierOptions(searchText: $viewModel.searchText)
        )
    }
}

private struct ScheduledMessageListRowView<Factory: ViewFactory>: View {
    let viewFactory: Factory
    let scheduledMessage: ScheduledMessage
    let channel: ChatChannel?
    let onItemTap: (@MainActor (ScheduledMessage) -> Void)?

    var body: some View {
        if let onItemTap, !scheduledMessage.isInProgress {
            Button {
                onItemTap(scheduledMessage)
            } label: {
                item()
            }
            .buttonStyle(.plain)
        } else {
            item()
        }
    }

    @ViewBuilder
    private func item() -> some View {
        viewFactory.makeScheduledMessageListItem(
            options: ScheduledMessageListItemOptions(scheduledMessage: scheduledMessage, channel: channel)
        )
    }
}
