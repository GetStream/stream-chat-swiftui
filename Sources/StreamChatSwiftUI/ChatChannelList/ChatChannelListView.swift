//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat channel list.
public struct ChatChannelListView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    @StateObject private var viewModel: ChatChannelListViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let viewFactory: Factory
    private let title: String
    private let customOnItemTap: (@MainActor (ChatChannel) -> Void)?
    private var embedInNavigationView: Bool
    private var handleTabBarVisibility: Bool

    /// Creates a channel list view.
    ///
    /// - Parameters:
    ///   - viewFactory: The view factory used for creating views used by the channel list.
    ///   - viewModel: The view model instance providing the data. Default view model is created if nil.
    ///   - channelListController: The channel list controller managing the list of channels used as a data souce for the view model. Default controller is created if nil.
    ///   - title: A title used as the navigation bar title.
    ///   - onItemTap: A closure for handling a tap on the channel item. Default closure updates the ``ChatChannelListViewModel/selectedChannel`` property in the view model.
    ///   - selectedChannelId: The id of a channel to be opened after the initial channel list load.
    ///   - handleTabBarVisibility: True, if TabBar visibility should be automatically updated.
    ///   - embedInNavigationView: True, if the channel list view should be embedded in a navigation stack.
    ///   - searchType: The type of data the channel list should perform a search. By default it searches messages.
    ///
    /// Changing the instance of the passed in `viewModel` or `channelListController` does not have an effect without reloading the channel list view by assigning a custom identity. The custom identity should be refreshed when either of the passed in instances have been recreated.
    /// ```swift
    /// ChatChannelListView(
    ///   viewModel: viewModel
    /// )
    /// .id(myCustomViewIdentity)
    /// ```
    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        viewModel: ChatChannelListViewModel? = nil,
        channelListController: ChatChannelListController? = nil,
        title: String = "Stream Chat",
        onItemTap: (@MainActor (ChatChannel) -> Void)? = nil,
        selectedChannelId: String? = nil,
        handleTabBarVisibility: Bool = true,
        embedInNavigationView: Bool = true,
        searchType: ChannelListSearchType = .messages
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeChannelListViewModel(
                channelListController: channelListController,
                selectedChannelId: selectedChannelId,
                searchType: searchType
            )
        )
        self.viewFactory = viewFactory
        self.title = title
        self.handleTabBarVisibility = handleTabBarVisibility
        self.embedInNavigationView = embedInNavigationView
        customOnItemTap = onItemTap
    }
    
    var onItemTap: @MainActor (ChatChannel) -> Void {
        if let customOnItemTap {
            return customOnItemTap
        }
        return { [weak viewModel] channel in
            viewModel?.selectedChannel = channel.channelSelectionInfo
        }
    }

    public var body: some View {
        containerView
            .sheet(isPresented: $viewModel.channelPopupShown, content: {
                channelPopup()
            })
            .if(!usesAdaptiveSplitView, transform: { view in
                view.navigationViewStyle(.stack)
            })
            .onAppear {
                viewModel.setSplitViewActive(usesAdaptiveSplitView)
            }
            .onChange(of: usesAdaptiveSplitView) { isActive in
                viewModel.setSplitViewActive(isActive)
            }
            .accessibilityIdentifier("ChatChannelListView")
    }

    @ViewBuilder
    private var containerView: some View {
        if usesAdaptiveSplitView {
            if #available(iOS 16, *) {
                GeometryReader { geometry in
                    let width = sidebarWidth(in: geometry)
                    NavigationSplitView {
                        splitViewSidebar(width: width)
                    } detail: {
                        if let width {
                            splitViewDetail()
                                .navigationSplitViewColumnWidth(min: 0, ideal: geometry.size.width - width)
                        } else {
                            splitViewDetail()
                        }
                    }
                    .accentColor(Color(colors.navigationBarTintColor))
                    .toolbar(
                        hidesTabBar(in: geometry) ? .hidden : .automatic,
                        for: .tabBar
                    )
                }
            }
        } else {
            NavigationContainerView(embedInNavigationView: embedInNavigationView) {
                content
            }
        }
    }

    @available(iOS 16, *)
    @ViewBuilder
    private func splitViewSidebar(width: CGFloat?) -> some View {
        if let width {
            content.navigationSplitViewColumnWidth(width)
        } else {
            content
        }
    }

    private func sidebarWidth(in geometry: GeometryProxy) -> CGFloat? {
        // Keep the split aligned with the hinge even when the display is flat.
        divisionRegionFrames(in: geometry).first {
            $0.height > $0.width
                && $0.minY <= 0 && $0.maxY >= geometry.size.height
                && $0.midX > 0 && $0.midX < geometry.size.width
        }?.midX
    }

    private func hidesTabBar(in geometry: GeometryProxy) -> Bool {
        guard handleTabBarVisibility,
              utils.messageListConfig.handleTabBarVisibility,
              viewModel.selectedChannel != nil else { return false }
        return divisionRegionFrames(in: geometry).contains { $0.width > $0.height }
    }

    private func divisionRegionFrames(in geometry: GeometryProxy) -> [CGRect] {
        #if compiler(>=6.4)
        if #available(iOS 27.1, *) {
            return geometry.reservedRegions(kind: .division, options: .includeInactive).map(\.frame)
        }
        #endif
        return []
    }

    private var content: some View {
        Group {
            if viewModel.loading {
                viewFactory.makeLoadingView(options: LoadingViewOptions())
            } else if viewModel.channels.isEmpty {
                viewFactory.makeEmptyChannelsView(options: EmptyChannelsViewOptions())
            } else {
                ChatChannelListContentView(
                    viewFactory: viewFactory,
                    viewModel: viewModel,
                    channelDestination: usesAdaptiveSplitView ? nil : channelDestination,
                    onItemTap: onItemTap
                )
            }
        }
        .onDisappear(perform: {
            if viewModel.selectedChannel != nil {
                viewModel.hideTabBar = true
            }
            if viewModel.swipedChannelId != nil {
                viewModel.swipedChannelId = nil
            }
        })
        .background(
            viewFactory.makeChannelListBackground(options: .init())
        )
        .background(
            !usesAdaptiveSplitView && handleTabBarVisibility ?
                Color.clear.background(
                    TabBarAccessor(isTabBarHidden: viewModel.hideTabBar)
                )
                .allowsHitTesting(false)
                : nil
        )
        .alert(isPresented: $viewModel.alertShown) {
            switch viewModel.channelAlertType {
            case let .deleteChannel(channel):
                Alert(
                    title: Text(L10n.Alert.Actions.deleteChannelTitle),
                    message: Text(L10n.Alert.Actions.deleteChannelMessage),
                    primaryButton: .destructive(Text(L10n.Alert.Actions.delete)) {
                        viewModel.delete(channel: channel)
                    },
                    secondaryButton: .cancel()
                )
            case let .muteChannel(channel):
                Alert(
                    title: Text(channel.isMuted ? L10n.Alert.Actions.unmuteChannel : L10n.Alert.Actions.muteChannel),
                    primaryButton: .default(Text(channel.isMuted ? L10n.Channel.Item.unmute : L10n.Channel.Item.mute)) {
                        viewModel.mute(channel: channel)
                    },
                    secondaryButton: .cancel()
                )
            default:
                Alert.defaultErrorAlert
            }
        }
        .modifier(viewFactory.makeChannelListHeaderViewModifier(options: ChannelListHeaderViewModifierOptions(title: title)))
        .navigationBarTitleDisplayMode(utils.channelListConfig.navigationBarDisplayMode)
    }

    private var usesAdaptiveSplitView: Bool {
        guard embedInNavigationView,
              horizontalSizeClass == .regular,
              utils.messageListConfig.iPadSplitViewEnabled else {
            return false
        }

        if #available(iOS 16, *) {
            return true
        } else {
            return false
        }
    }

    private var channelDestination: @MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination {
        viewFactory.makeChannelDestination(options: ChannelDestinationOptions())
    }

    @ViewBuilder
    private func channelPopup() -> some View {
        switch viewModel.channelPopupType {
        case let .moreActions(channel):
            viewFactory.makeMoreChannelActionsView(
                options: MoreChannelActionsViewOptions(
                    channel: channel,
                    swipedChannelId: $viewModel.swipedChannelId,
                    onDismiss: {
                        withAnimation {
                            viewModel.channelPopupType = nil
                            viewModel.swipedChannelId = nil
                        }
                    },
                    onError: { error in
                        viewModel.showErrorPopup(error)
                    }
                )
            )
        default:
            EmptyView()
        }
    }

    @available(iOS 16.0, *)
    @ViewBuilder
    private func splitViewDetail() -> some View {
        SplitViewDetailStack(selectionId: viewModel.selectedChannel?.id) {
            if let selectedChannel = viewModel.selectedChannel {
                channelDestination(selectedChannel)
            } else {
                viewFactory.makeMessageListBackground(
                    options: MessageListBackgroundOptions(isInThread: false)
                )
                .accessibilityIdentifier("ChatChannelListSplitDetailPlaceholder")
            }
        }
        .environment(\.isInChatNavigationSplitView, true)
    }
}

// The split view reuses the detail column's navigation controller when the selection
// changes, so screens pushed on top of a channel (e.g. channel info) have to be popped.
@available(iOS 16, *)
private struct SplitViewDetailStack<Content: View>: View {
    let selectionId: String?
    @ViewBuilder let content: () -> Content

    @State private var navigationController = WeakNavigationController()

    var body: some View {
        NavigationStack {
            content()
                .background(NavigationControllerAccessor { navigationController.value = $0 })
        }
        .id(selectionId)
        .onChange(of: selectionId) { _ in
            navigationController.value?.popToRootViewController(animated: false)
        }
    }
}

@MainActor private final class WeakNavigationController {
    weak var value: UINavigationController?
}

private struct NavigationControllerAccessor: UIViewControllerRepresentable {
    let onResolve: (UINavigationController) -> Void

    func makeUIViewController(context: Context) -> ViewController {
        ViewController(onResolve: onResolve)
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}

    final class ViewController: UIViewController {
        let onResolve: (UINavigationController) -> Void

        init(onResolve: @escaping (UINavigationController) -> Void) {
            self.onResolve = onResolve
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let navigationController {
                onResolve(navigationController)
            }
        }
    }
}

extension ChatChannelListView where Factory == DefaultViewFactory {
    public init() {
        self.init(viewFactory: DefaultViewFactory.shared)
    }
}

public struct ChatChannelListContentView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var viewFactory: Factory
    @ObservedObject private var viewModel: ChatChannelListViewModel
    private var channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)?
    private var onItemTap: @MainActor (ChatChannel) -> Void

    public init(
        viewFactory: Factory,
        viewModel: ChatChannelListViewModel,
        channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)? = nil,
        onItemTap: (@MainActor (ChatChannel) -> Void)? = nil
    ) {
        self.viewFactory = viewFactory
        self.viewModel = viewModel
        self.channelDestination = channelDestination
        if let onItemTap {
            self.onItemTap = onItemTap
        } else {
            self.onItemTap = { channel in
                viewModel.selectedChannel = channel.channelSelectionInfo
            }
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            viewFactory.makeChannelListTopView(
                options: ChannelListTopViewOptions()
            )
            
            if viewModel.isSearching {
                viewFactory.makeSearchResultsView(
                    options: SearchResultsViewOptions(
                        selectedChannel: $viewModel.selectedChannel,
                        searchResults: viewModel.searchResults,
                        loadingSearchResults: viewModel.loadingSearchResults,
                        channelNaming: viewModel.name(forChannel:),
                        onSearchResultTap: { searchResult in
                            viewModel.selectedChannel = searchResult
                        },
                        onItemAppear: viewModel.loadAdditionalSearchResults(index:)
                    )
                )
            } else {
                ChannelList(
                    factory: viewFactory,
                    channels: viewModel.channels,
                    selectedChannel: $viewModel.selectedChannel,
                    swipedChannelId: $viewModel.swipedChannelId,
                    scrolledChannelId: $viewModel.scrolledChannelId,
                    scrollable: true,
                    onItemTap: onItemTap,
                    onItemAppear: { index in
                        viewModel.checkTabBarAppearance()
                        viewModel.checkForChannels(index: index)
                    },
                    channelDestination: channelDestination,
                    trailingSwipeRightButtonTapped: viewModel.onMuteTapped(channel:),
                    trailingSwipeLeftButtonTapped: viewModel.onMoreTapped(channel:),
                    leadingSwipeButtonTapped: { _ in }
                )
            }

            viewFactory.makeChannelListStickyFooterView(options: ChannelListStickyFooterViewOptions())
        }
        .modifier(viewFactory.styles.makeSearchableModifier(
            options: SearchableModifierOptions(searchText: $viewModel.searchText)
        ))
        .background(Color(colors.backgroundCoreApp))
        .modifier(viewFactory.styles.makeChannelListContentModifier(options: ChannelListContentModifierOptions()))
    }
}
