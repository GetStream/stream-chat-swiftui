//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ChatChannelInfoView: View, KeyboardReadable {
    
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    @StateObject private var viewModel: ChatChannelInfoViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(channel: ChatChannel) {
        _viewModel = StateObject(
            wrappedValue: ChatChannelInfoViewModel(channel: channel)
        )
    }
    
    public var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.channel.isDirectMessageChannel {
                        ChatInfoDirectChannelView(
                            participant: viewModel.displayedParticipants.first
                        )
                    } else {
                        ChatInfoParticipantsView(
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
                    
                    ChatInfoOptionsView(viewModel: viewModel)
                    
                    ChannelInfoDivider()
                        .alert(isPresented: $viewModel.errorShown) {
                            Alert.defaultErrorAlert
                        }
                    
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
                                }
                            },
                            secondaryButton: .cancel()
                        )
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
                    AddUsersView(
                        loadedUserIds: viewModel.participants.map(\.id),
                        onUserTap: viewModel.addUserTapped(_:)
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Group {
                    if viewModel.channel.isDirectMessageChannel {
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
                viewModel.channel.isDirectMessageChannel ? nil :
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
        .onReceive(keyboardWillChangePublisher) { visible in
            viewModel.keyboardShown = visible
        }
        .modifier(
            HideKeyboardOnTapGesture(shouldAdd: viewModel.keyboardShown)
        )
    }
}
