//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

// View for the channel info screen.
public struct ChatChannelInfoView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    let factory: Factory
    
    @StateObject private var viewModel: ChatChannelInfoViewModel
    private var shownFromMessageList: Bool

    @Environment(\.presentationMode) var presentationMode
    
    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        shownFromMessageList: Bool = false
    ) {
        _viewModel = StateObject(
            wrappedValue: ChatChannelInfoViewModel(channel: channel)
        )
        self.factory = factory
        self.shownFromMessageList = shownFromMessageList
    }

    init(
        factory: Factory = DefaultViewFactory.shared,
        viewModel: ChatChannelInfoViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.factory = factory
        shownFromMessageList = false
    }

    public var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.showSingleMemberDMView {
                        ChatInfoDirectChannelView(
                            factory: factory,
                            participant: viewModel.displayedParticipants.first
                        )
                    } else {
                        ChatInfoParticipantsView(
                            factory: factory,
                            participants: viewModel.displayedParticipants,
                            onItemAppear: viewModel.onParticipantAppear(_:)
                        )
                    }

                    if viewModel.showMoreUsersButton {
                        ChatChannelInfoButton(
                            title: L10n.ChatInfo.Users.loadMore(viewModel.notDisplayedParticipantsCount),
                            iconName: "chevron.down",
                            foregroundColor: Color(colors.textLowEmphasis)
                        ) {
                            viewModel.memberListCollapsed = false
                        }
                    }

                    ChannelInfoDivider()

                    ChatInfoOptionsView(factory: factory, viewModel: viewModel)

                    ChannelInfoDivider()
                        .alert(isPresented: $viewModel.errorShown) {
                            Alert.defaultErrorAlert
                        }

                    if viewModel.shouldShowLeaveConversationButton {
                        ChatChannelInfoButton(
                            title: viewModel.leaveButtonTitle,
                            iconName: "person.fill.xmark",
                            foregroundColor: Color(colors.alert)
                        ) {
                            viewModel.leaveGroupAlertShown = true
                        }
                        .alert(isPresented: $viewModel.leaveGroupAlertShown) {
                            let title = viewModel.leaveButtonTitle
                            let message = viewModel.leaveConversationDescription
                            let buttonTitle = viewModel.leaveButtonTitle

                            return Alert(
                                title: Text(title),
                                message: Text(message),
                                primaryButton: .destructive(Text(buttonTitle)) {
                                    viewModel.leaveConversationTapped {
                                        presentationMode.wrappedValue.dismiss()
                                        if shownFromMessageList {
                                            notifyChannelDismiss()
                                        }
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
            }
            .overlay(
                viewModel.addUsersShown ?
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all) : nil
            )
            .blur(radius: viewModel.addUsersShown ? 6 : 0)
            .allowsHitTesting(!viewModel.addUsersShown)

            if viewModel.addUsersShown {
                VStack {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .layoutPriority(-1)
                        .onTapGesture {
                            viewModel.addUsersShown = false
                        }
                        .accessibilityAction {
                            viewModel.addUsersShown = false
                        }
                    AddUsersView(
                        factory: factory,
                        loadedUserIds: viewModel.participants.map(\.id),
                        onUserTap: viewModel.addUserTapped(_:)
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Group {
                    if viewModel.showSingleMemberDMView {
                        Text(viewModel.displayedParticipants.first?.chatUser.name ?? "")
                            .font(fonts.bodyBold)
                            .foregroundColor(Color(colors.text))
                    } else {
                        ChannelTitleView(
                            channel: viewModel.channel,
                            shouldShowTypingIndicator: false
                        )
                        .id(viewModel.channelId)
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.shouldShowAddUserButton {
                    Button {
                        viewModel.addUsersShown = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .customizable()
                            .foregroundColor(Color.white)
                            .padding(.all, 8)
                            .background(colors.tintColor)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .onReceive(keyboardWillChangePublisher) { visible in
            viewModel.keyboardShown = visible
        }
        .dismissKeyboardOnTap(enabled: viewModel.keyboardShown)
        .background(Color(colors.background).edgesIgnoringSafeArea(.bottom))
    }
}
