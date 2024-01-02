//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct iMessagePocView: View {

    @Injected(\.colors) var colors

    @StateObject var viewModel: iMessageChatChannelListViewModel
    @StateObject private var channelHeaderLoader = ChannelHeaderLoader()

    private var factory = iMessageViewFactory.shared

    init() {
        _viewModel = StateObject(
            wrappedValue:
            iMessageChatChannelListViewModel(
                channelListController: nil,
                selectedChannelId: nil
            )
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.pinnedChannels.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(viewModel.pinnedChannels) { channel in
                                ChannelAvatarView(
                                    avatar: channelHeaderLoader.image(for: channel),
                                    showOnlineIndicator: false
                                )
                                .padding()
                            }
                        }
                    }
                    .frame(height: 60)
                }
                ChannelList(
                    factory: factory,
                    channels: viewModel.channels,
                    selectedChannel: $viewModel.selectedChannel,
                    swipedChannelId: $viewModel.swipedChannelId,
                    onlineIndicatorShown: viewModel.onlineIndicatorShown(for:),
                    imageLoader: channelHeaderLoader.image(for:),
                    onItemTap: { channel in
                        viewModel.selectedChannel = ChannelSelectionInfo(channel: channel, message: nil)
                    },
                    onItemAppear: viewModel.checkForChannels(index:),
                    channelNaming: viewModel.name(forChannel:),
                    channelDestination: factory.makeChannelDestination(),
                    trailingSwipeRightButtonTapped: viewModel.onDeleteTapped(channel:),
                    trailingSwipeLeftButtonTapped: viewModel.onMoreTapped(channel:),
                    leadingSwipeButtonTapped: viewModel.pinChannelTapped(_:)
                )
                .alert(isPresented: $viewModel.alertShown) {
                    switch viewModel.channelAlertType {
                    case let .deleteChannel(channel):
                        return Alert(
                            title: Text("Delete"),
                            message: Text("Are you sure you want to delete this channel?"),
                            primaryButton: .destructive(Text("Delete")) {
                                viewModel.delete(channel: channel)
                            },
                            secondaryButton: .cancel()
                        )
                    default:
                        return Alert.defaultErrorAlert
                    }
                }

                Spacer()
            }
            .blur(radius: (viewModel.customAlertShown || viewModel.alertShown) ? 6 : 0)
            .overlay(viewModel.customAlertShown ? customViewOverlay() : nil)
            .accentColor(colors.tintColor)
            .navigationTitle("Messages")
        }
    }

    @ViewBuilder
    private func customViewOverlay() -> some View {
        switch viewModel.customChannelPopupType {
        case let .moreActions(channel):
            factory.makeMoreChannelActionsView(
                for: channel,
                swipedChannelId: $viewModel.swipedChannelId
            ) {
                withAnimation {
                    viewModel.customChannelPopupType = nil
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

class iMessageChatChannelListViewModel: ChatChannelListViewModel {

    @Published var pinnedChannels = [ChatChannel]()

    func pinChannelTapped(_ channel: ChatChannel) {
        if !pinnedChannels.contains(channel) {
            pinnedChannels.append(channel)
        }
    }
}

class iMessageViewFactory: ViewFactory {

    @Injected(\.chatClient) var chatClient
    @Injected(\.colors) var colors

    static let shared = iMessageViewFactory()

    private init() {}

    func makeLeadingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        buttonTapped: @escaping (ChatChannel) -> Void
    ) -> some View {
        HStack {
            ActionItemButton(imageName: "pin.fill") {
                buttonTapped(channel)
            }
            .frame(width: buttonWidth)
            .foregroundColor(Color.white)
            .background(Color.yellow)

            Spacer()
        }
    }
}
