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
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    @StateObject private var viewModel: ScheduledMessageListViewModel

    private let viewFactory: Factory
    private let title: String
    private let embedInNavigationView: Bool

    /// Creates a scheduled message list view.
    ///
    /// - Parameters:
    ///   - viewFactory: The view factory used for creating views used by the scheduled message list.
    ///   - viewModel: The view model providing the data. It is created once, when the view first appears.
    ///   - title: A custom title used as the navigation bar title.
    ///   - embedInNavigationView: True, if the scheduled message list view should be embedded in a navigation stack.
    ///
    /// Changing the instance of the passed in `viewModel` does not have an effect without reloading the scheduled
    /// message list view by assigning a custom identity.
    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        viewModel: @autoclosure @escaping () -> ScheduledMessageListViewModel,
        title: String? = nil,
        embedInNavigationView: Bool = true
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.viewFactory = viewFactory
        self.title = title ?? L10n.ScheduledMessages.title
        self.embedInNavigationView = embedInNavigationView
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
                                    onTap: { viewModel.scheduledMessageTapped(scheduledMessage) }
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
            .snackBar(
                text: $viewModel.snackBarText,
                icon: viewModel.snackBarShowsErrorIcon ? images.snackBarError : nil,
                showsSpinner: viewModel.snackBarShowsSpinner,
                bottomOffset: tokens.spacingMd
            )
            .sheet(item: $viewModel.selectedScheduledMessage, onDismiss: { viewModel.actionsSheetDismissed() }) {
                viewFactory.makeScheduledMessageActionsSheet(options: actionsSheetOptions(for: $0))
            }
            .sheet(item: $viewModel.rescheduledScheduledMessage, content: rescheduleSheet)
            .modifier(ConfirmationAlertModifier(
                isPresented: $viewModel.deleteConfirmationShown,
                confirmation: viewModel.deleteConfirmation,
                onConfirm: { viewModel.deleteConfirmed() }
            ))
        }
        .accessibilityIdentifier("ScheduledMessageListView")
    }

    private func actionsSheetOptions(for scheduledMessage: ScheduledMessage) -> ScheduledMessageActionsSheetOptions {
        ScheduledMessageActionsSheetOptions(
            scheduledMessage: scheduledMessage,
            onCopyText: { viewModel.copyText(of: scheduledMessage) },
            onDelete: { viewModel.delete(scheduledMessage) },
            onReschedule: { viewModel.reschedule(scheduledMessage) },
            onSendNow: { viewModel.sendNow(scheduledMessage) },
            onDismiss: { viewModel.selectedScheduledMessage = nil }
        )
    }

    @ViewBuilder private func rescheduleSheet(for scheduledMessage: ScheduledMessage) -> some View {
        if let channel = viewModel.channel(of: scheduledMessage) {
            viewFactory.makeScheduleMessageCustomTimeSheet(
                options: ScheduleMessageCustomTimeSheetOptions(
                    channel: channel,
                    usage: viewModel.rescheduleUsage,
                    preview: viewModel.reschedulePreview(for: scheduledMessage),
                    scheduledMessage: scheduledMessage,
                    validate: { viewModel.validateReschedule(of: scheduledMessage, at: $0, completion: $1) },
                    onSchedule: { viewModel.rescheduleConfirmed(at: $0) },
                    onDismiss: { viewModel.rescheduledScheduledMessage = nil }
                )
            )
        }
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
    let onTap: @MainActor () -> Void

    var body: some View {
        Button(action: onTap) {
            viewFactory.makeScheduledMessageListItem(
                options: ScheduledMessageListItemOptions(scheduledMessage: scheduledMessage)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
