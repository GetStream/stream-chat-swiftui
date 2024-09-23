//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat channel list.
public struct ChatChannelListView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    @StateObject private var viewModel: ChatChannelListViewModel
    @State private var tabBar: UITabBar?

    private let viewFactory: Factory
    private let title: String
    private let customOnItemTap: ((ChatChannel) -> Void)?
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
        onItemTap: ((ChatChannel) -> Void)? = nil,
        selectedChannelId: String? = nil,
        handleTabBarVisibility: Bool = true,
        embedInNavigationView: Bool = true
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeChannelListViewModel(
                channelListController: channelListController,
                selectedChannelId: selectedChannelId
            )
        )
        self.viewFactory = viewFactory
        self.title = title
        self.handleTabBarVisibility = handleTabBarVisibility
        self.embedInNavigationView = embedInNavigationView
        customOnItemTap = onItemTap
    }
    
    var onItemTap: (ChatChannel) -> Void {
        if let customOnItemTap {
            return customOnItemTap
        }
        return { [weak viewModel] channel in
            viewModel?.selectedChannel = channel.channelSelectionInfo
        }
    }

    public var body: some View {
        container()
            .overlay(viewModel.customAlertShown ? customViewOverlay() : nil)
            .accentColor(colors.tintColor)
            .if(isIphone || !utils.messageListConfig.iPadSplitViewEnabled, transform: { view in
                view.navigationViewStyle(.stack)
            })
            .background(
                isIphone && handleTabBarVisibility ?
                    Color.clear.background(
                        TabBarAccessor { tabBar in
                            self.tabBar = tabBar
                        }
                    )
                    .allowsHitTesting(false)
                    : nil
            )
            .onReceive(viewModel.$hideTabBar) { newValue in
                if isIphone && handleTabBarVisibility {
                    self.setupTabBarAppeareance()
                    self.tabBar?.isHidden = newValue
                }
            }
            .accessibilityIdentifier("ChatChannelListView")
    }

    @ViewBuilder
    private func container() -> some View {
        if embedInNavigationView == true {
            if #available(iOS 16, *), isIphone {
                NavigationStack {
                    content()
                }
            } else {
                NavigationView {
                    content()
                }
            }
        } else {
            content()
        }
    }

    @ViewBuilder
    private func content() -> some View {
        Group {
            if viewModel.loading {
                viewFactory.makeLoadingView()
            } else if viewModel.channels.isEmpty {
                viewFactory.makeNoChannelsView()
            } else {
                ChatChannelListContentView(
                    viewFactory: viewFactory,
                    viewModel: viewModel,
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
            viewFactory.makeChannelListBackground(colors: colors)
        )
        .alert(isPresented: $viewModel.alertShown) {
            switch viewModel.channelAlertType {
            case let .deleteChannel(channel):
                return Alert(
                    title: Text(L10n.Alert.Actions.deleteChannelTitle),
                    message: Text(L10n.Alert.Actions.deleteChannelMessage),
                    primaryButton: .destructive(Text(L10n.Alert.Actions.delete)) {
                        viewModel.delete(channel: channel)
                    },
                    secondaryButton: .cancel()
                )
            default:
                return Alert.defaultErrorAlert
            }
        }
        .modifier(viewFactory.makeChannelListHeaderViewModifier(title: title))
        .navigationBarTitleDisplayMode(viewFactory.navigationBarDisplayMode())
        .blur(radius: (viewModel.customAlertShown || viewModel.alertShown) ? 6 : 0)
    }

    private func setupTabBarAppeareance() {
        if #available(iOS 15.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    @ViewBuilder
    private func customViewOverlay() -> some View {
        switch viewModel.customChannelPopupType {
        case let .moreActions(channel):
            viewFactory.makeMoreChannelActionsView(
                for: channel,
                swipedChannelId: $viewModel.swipedChannelId
            ) {
                withAnimation {
                    viewModel.customChannelPopupType = nil
                    viewModel.swipedChannelId = nil
                }
            } onError: { error in
                viewModel.showErrorPopup(error)
            }
            .edgesIgnoringSafeArea(.bottom)
        default:
            EmptyView()
        }
    }
}

extension ChatChannelListView where Factory == DefaultViewFactory {
    public init() {
        self.init(viewFactory: DefaultViewFactory.shared)
    }
}

public struct ChatChannelListContentView<Factory: ViewFactory>: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var viewFactory: Factory
    @ObservedObject private var viewModel: ChatChannelListViewModel
    private var channelHeaderLoader: ChannelHeaderLoader { InjectedValues[\.utils].channelHeaderLoader }
    private var onItemTap: (ChatChannel) -> Void

    public init(
        viewFactory: Factory,
        viewModel: ChatChannelListViewModel,
        onItemTap: ((ChatChannel) -> Void)? = nil
    ) {
        self.viewFactory = viewFactory
        self.viewModel = viewModel
        if let onItemTap = onItemTap {
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
                searchText: $viewModel.searchText
            )

            if viewModel.isSearching {
                viewFactory.makeSearchResultsView(
                    selectedChannel: $viewModel.selectedChannel,
                    searchResults: viewModel.searchResults,
                    loadingSearchResults: viewModel.loadingSearchResults,
                    onlineIndicatorShown: viewModel.onlineIndicatorShown(for:),
                    channelNaming: viewModel.name(forChannel:),
                    imageLoader: channelHeaderLoader.image(for:),
                    onSearchResultTap: { searchResult in
                        viewModel.selectedChannel = searchResult
                    },
                    onItemAppear: viewModel.loadAdditionalSearchResults(index:)
                )
            } else {
                ChannelList(
                    factory: viewFactory,
                    channels: viewModel.channels,
                    selectedChannel: $viewModel.selectedChannel,
                    swipedChannelId: $viewModel.swipedChannelId,
                    onlineIndicatorShown: viewModel.onlineIndicatorShown(for:),
                    imageLoader: channelHeaderLoader.image(for:),
                    onItemTap: onItemTap,
                    onItemAppear: { index in
                        viewModel.checkTabBarAppearance()
                        viewModel.checkForChannels(index: index)
                    },
                    channelNaming: viewModel.name(forChannel:),
                    channelDestination: viewFactory.makeChannelDestination(),
                    trailingSwipeRightButtonTapped: viewModel.onDeleteTapped(channel:),
                    trailingSwipeLeftButtonTapped: viewModel.onMoreTapped(channel:),
                    leadingSwipeButtonTapped: { _ in /* No leading button by default. */ }
                )
                .onAppear {
                    if horizontalSizeClass == .regular {
                        viewModel.preselectChannelIfNeeded()
                    }
                }
            }

            viewFactory.makeChannelListStickyFooterView()
        }
        .modifier(viewFactory.makeChannelListContentModifier())
    }
}
