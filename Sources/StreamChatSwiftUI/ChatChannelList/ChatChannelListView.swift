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
    private var onItemTap: (ChatChannel) -> Void
    private var embedInNavigationView: Bool
    private var handleTabBarVisibility: Bool

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
        let channelListVM = viewModel ?? ViewModelsFactory.makeChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: selectedChannelId
        )
        _viewModel = StateObject(
            wrappedValue: channelListVM
        )
        self.viewFactory = viewFactory
        self.title = title
        self.handleTabBarVisibility = handleTabBarVisibility
        self.embedInNavigationView = embedInNavigationView
        if let onItemTap = onItemTap {
            self.onItemTap = onItemTap
        } else {
            self.onItemTap = { channel in
                channelListVM.selectedChannel = channel.channelSelectionInfo
            }
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
    @ObservedObject private var channelHeaderLoader = InjectedValues[\.utils].channelHeaderLoader
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
