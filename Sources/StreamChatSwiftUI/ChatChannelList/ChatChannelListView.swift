//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat channel list.
public struct ChatChannelListView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    @StateObject private var viewModel: ChatChannelListViewModel
    @StateObject private var channelHeaderLoader = ChannelHeaderLoader()
    
    private let viewFactory: Factory
    private let title: String
    private var onItemTap: (ChatChannel) -> Void
    private var channelDestination: (ChannelSelectionInfo) -> Factory.ChannelDestination
    
    public init(
        viewFactory: Factory,
        channelListController: ChatChannelListController? = nil,
        title: String = "Stream Chat",
        onItemTap: ((ChatChannel) -> Void)? = nil,
        selectedChannelId: String? = nil
    ) {
        let channelListVM = ViewModelsFactory.makeChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: selectedChannelId
        )
        _viewModel = StateObject(
            wrappedValue: channelListVM
        )
        self.viewFactory = viewFactory
        self.title = title
        if let onItemTap = onItemTap {
            self.onItemTap = onItemTap
        } else {
            self.onItemTap = { channel in
                channelListVM.selectedChannel = channel.channelSelectionInfo
            }
        }
        
        channelDestination = viewFactory.makeChannelDestination()
    }
    
    public var body: some View {
        NavigationView {
            Group {
                if viewModel.loading {
                    viewFactory.makeLoadingView()
                } else if viewModel.channels.isEmpty {
                    viewFactory.makeNoChannelsView()
                } else {
                    ZStack {
                        ChannelDeepLink(
                            deeplinkChannel: $viewModel.deeplinkChannel,
                            channelDestination: channelDestination
                        )
                        
                        VStack {
                            viewFactory.makeChannelListTopView(
                                searchText: $viewModel.searchText
                            )
                            
                            if viewModel.isSearching {
                                SearchResultsView(
                                    factory: viewFactory,
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
                                    onItemAppear: viewModel.checkForChannels(index:),
                                    channelNaming: viewModel.name(forChannel:),
                                    channelDestination: channelDestination,
                                    trailingSwipeRightButtonTapped: viewModel.onDeleteTapped(channel:),
                                    trailingSwipeLeftButtonTapped: viewModel.onMoreTapped(channel:),
                                    leadingSwipeButtonTapped: { _ in }
                                )
                            }
                        }
                    }
                }
            }
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
        .overlay(viewModel.customAlertShown ? customViewOverlay() : nil)
        .accentColor(colors.tintColor)
        .if(isIphone, transform: { view in
            view.navigationViewStyle(.stack)
        })
    }
    
    private var isIphone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
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
            .edgesIgnoringSafeArea(.all)
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
