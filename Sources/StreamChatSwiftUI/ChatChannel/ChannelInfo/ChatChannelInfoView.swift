//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ChatChannelInfoView: View {
    
    @Injected(\.images) private var images
    
    @StateObject private var viewModel: ChatChannelInfoViewModel
    
    public init(channel: ChatChannel) {
        _viewModel = StateObject(
            wrappedValue: ChatChannelInfoViewModel(channel: channel)
        )
    }
    
    public var body: some View {
        VStack {
            Divider()
            
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
            
            Divider()
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ChannelTitleView(
                    channel: viewModel.channel,
                    shouldShowTypingIndicator: false
                )
            }
        }
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
