//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct iMessagePocView: View {
    @Injected(\.colors) var colors

    @StateObject var viewModel: iMessageChatChannelListViewModel

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
                                ChannelAvatar(
                                    channel: channel,
                                    size: 48,
                                    indicator: false
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
                    onItemTap: { channel in
                        viewModel.selectedChannel = ChannelSelectionInfo(channel: channel, message: nil)
                    },
                    onItemAppear: viewModel.checkForChannels(index:),
                    channelDestination: factory.makeChannelDestination(options: ChannelDestinationOptions()),
                    trailingSwipeRightButtonTapped: viewModel.onDeleteTapped(channel:),
                    trailingSwipeLeftButtonTapped: viewModel.onMoreTapped(channel:),
                    leadingSwipeButtonTapped: viewModel.pinChannelTapped(_:)
                )
                .alert(isPresented: $viewModel.alertShown) {
                    switch viewModel.channelAlertType {
                    case let .deleteChannel(channel):
                        Alert(
                            title: Text("Delete"),
                            message: Text("Are you sure you want to delete this channel?"),
                            primaryButton: .destructive(Text("Delete")) {
                                viewModel.delete(channel: channel)
                            },
                            secondaryButton: .cancel()
                        )
                    default:
                        Alert.defaultErrorAlert
                    }
                }

                Spacer()
            }
            .blur(radius: (viewModel.customAlertShown || viewModel.alertShown) ? 6 : 0)
            .overlay(viewModel.customAlertShown ? customViewOverlay() : nil)
            .accentColor(Color(colors.accentPrimary))
            .navigationTitle("Messages")
        }
    }

    @ViewBuilder
    private func customViewOverlay() -> some View {
        switch viewModel.customChannelPopupType {
        case let .moreActions(channel):
            factory.makeMoreChannelActionsView(
                options: .init(
                    channel: channel,
                    swipedChannelId: $viewModel.swipedChannelId
                ) {
                    withAnimation {
                        viewModel.customChannelPopupType = nil
                    }
                } onError: { error in
                    viewModel.showErrorPopup(error)
                }
            )
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

    public var styles = LiquidGlassStyles()
    
    private init() {}

    func makeLeadingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        buttonTapped: @escaping @MainActor (ChatChannel) -> Void
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
