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
        ScrollView {
            LazyVStack(spacing: 0) {
                ChatInfoParticipantsView(
                    participants: viewModel.displayedParticipants,
                    onItemAppear: viewModel.onParticipantAppear(_:)
                )
                
                if viewModel.memberListCollapsed && viewModel.notDisplayedParticipantsCount > 0 {
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ChannelTitleView(
                        channel: viewModel.channel,
                        shouldShowTypingIndicator: false
                    )
                    .id(viewModel.channelId)
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
}

struct ChatChannelInfoButton: View {
    
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    var title: String
    var iconName: String
    var foregroundColor: Color
    var buttonTapped: () -> Void
    
    var body: some View {
        Button {
            buttonTapped()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                Text(title)
                Spacer()
            }
        }
        .padding()
        .font(fonts.bodyBold)
        .foregroundColor(foregroundColor)
        .background(Color(colors.background))
    }
}

struct ChannelInfoDivider: View {
    
    @Injected(\.colors) private var colors
    
    var body: some View {
        Rectangle()
            .fill(Color(colors.innerBorder))
            .frame(height: 8)
    }
}

struct ChatInfoOptionsView: View {
    
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    @StateObject var viewModel: ChatChannelInfoViewModel
        
    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.channel.isDirectMessageChannel {
                ChannelNameUpdateView(viewModel: viewModel)
            }
            
            ChannelInfoItemView(icon: images.muted, title: viewModel.mutedText) {
                Toggle(isOn: $viewModel.muted) {
                    EmptyView()
                }
            }
            
            Divider()
            
            NavigatableChatInfoItemView(
                icon: images.pin,
                title: L10n.ChatInfo.PinnedMessages.title
            ) {
                PinnedMessagesView(channel: viewModel.channel)
            }
            
            Divider()
            
            NavigatableChatInfoItemView(
                icon: UIImage(systemName: "photo")!,
                title: L10n.ChatInfo.Media.title
            ) {
                MediaAttachmentsView(channel: viewModel.channel)
            }
            
            Divider()
            
            NavigatableChatInfoItemView(
                icon: UIImage(systemName: "folder")!,
                title: L10n.ChatInfo.Files.title
            ) {
                FileAttachmentsView(channel: viewModel.channel)
            }
        }
    }
}

struct ChannelNameUpdateView: View {
    
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    @StateObject var viewModel: ChatChannelInfoViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Text(L10n.ChatInfo.Rename.name)
                .font(fonts.footnote)
                .foregroundColor(Color(colors.textLowEmphasis))
            
            TextField(L10n.ChatInfo.Rename.placeholder, text: $viewModel.channelName)
                .font(fonts.body)
                .foregroundColor(Color(colors.text))
            
            Spacer()
            
            if viewModel.keyboardShown {
                Button {
                    viewModel.cancelGroupRenaming()
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
                
                Button {
                    viewModel.confirmGroupRenaming()
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(colors.tintColor)
                }
            }
        }
        .padding()
        .background(Color(colors.background))
    }
}

struct NavigatableChatInfoItemView<Destination: View>: View {
    
    let icon: UIImage
    let title: String
    var destination: () -> Destination
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            ChannelInfoItemView(icon: icon, title: title) {
                DisclosureIndicatorView()
            }
        }
    }
}

struct DisclosureIndicatorView: View {
    
    @Injected(\.colors) private var colors
    
    var body: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(Color(colors.textLowEmphasis))
    }
}

struct ChannelInfoItemView<TrailingView: View>: View {
    
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    let icon: UIImage
    let title: String
    var trailingView: () -> TrailingView
    
    var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: icon)
                .customizable()
                .frame(width: 24)
                .foregroundColor(Color(colors.textLowEmphasis))
            
            Text(title)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.text))
            
            Spacer()
            
            trailingView()
        }
        .padding()
    }
}
