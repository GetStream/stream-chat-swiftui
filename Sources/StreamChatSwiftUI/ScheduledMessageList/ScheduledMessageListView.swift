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
            VStack(spacing: 0) {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .snackBar(
                        text: $viewModel.snackBarText,
                        icon: viewModel.snackBarShowsErrorIcon ? images.snackBarError : nil,
                        showsSpinner: viewModel.snackBarShowsSpinner,
                        bottomOffset: tokens.spacingMd
                    )
                if let scheduledMessage = viewModel.editedScheduledMessage,
                   let channelController = viewModel.editedScheduledMessageChannelController {
                    viewFactory.makeMessageComposerViewType(
                        options: MessageComposerViewTypeOptions(
                            channelController: channelController,
                            messageController: viewModel.editedScheduledMessageThreadController,
                            quotedMessage: .constant(nil),
                            editedMessage: .constant(nil),
                            editedScheduledMessage: $viewModel.editedScheduledMessage,
                            willSendMessage: {}
                        )
                    )
                    .id(scheduledMessage.id)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(HiddenTabBarSafeAreaModifier())
            .background(Color(colors.backgroundCoreApp).ignoresSafeArea(edges: .bottom))
            .modifier(ChatThreadListHeaderViewModifier(title: title))
            .onAppear {
                viewModel.viewDidAppear()
            }
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

    @ViewBuilder private var content: some View {
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
                        .onAppear {
                            if let index = viewModel.scheduledMessages.firstIndex(where: { $0.id == scheduledMessage.id }) {
                                viewModel.didAppearScheduledMessage(at: index)
                            }
                        }
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

    private func actionsSheetOptions(for scheduledMessage: ScheduledMessage) -> ScheduledMessageActionsSheetOptions {
        let onEdit: (@MainActor () -> Void)? = viewModel.canEdit(scheduledMessage)
            ? { @MainActor in viewModel.edit(scheduledMessage) }
            : nil
        let onReschedule: (@MainActor () -> Void)? = viewModel.canReschedule(scheduledMessage)
            ? { @MainActor in viewModel.reschedule(scheduledMessage) }
            : nil
        return ScheduledMessageActionsSheetOptions(
            scheduledMessage: scheduledMessage,
            onCopyText: { viewModel.copyText(of: scheduledMessage) },
            onDelete: { viewModel.delete(scheduledMessage) },
            onEdit: onEdit,
            onReschedule: onReschedule,
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

// Opened from a channel, the list still gets the bottom safe area of the tab bar, which the channel list hides through
// UIKit. Like `ChatChannelView`, the bottom is laid out from the window's safe area then, except above the keyboard.
private struct HiddenTabBarSafeAreaModifier: ViewModifier, KeyboardReadable {
    @State private var isTabBarHidden = false
    @State private var keyboardShown = false

    func body(content: Content) -> some View {
        content
            .padding(.bottom, isTabBarHidden && !keyboardShown ? topVC()?.view.safeAreaInsets.bottom ?? 0 : 0)
            .ignoresSafeArea(.container, edges: isTabBarHidden ? .bottom : [])
            .background(
                TabBarAccessor { tabBar in
                    isTabBarHidden = tabBar.isHidden
                }
                .allowsHitTesting(false)
            )
            .onReceive(keyboardWillChangePublisher) { visible in
                keyboardShown = visible
            }
    }
}
