//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ChatChannelInfoButton: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var title: String
    var iconName: String
    var foregroundColor: Color
    var buttonTapped: () -> Void
    
    public init(title: String, iconName: String, foregroundColor: Color, buttonTapped: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        self.foregroundColor = foregroundColor
        self.buttonTapped = buttonTapped
    }
    
    public var body: some View {
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
        .background(Color(colors.background8))
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

public struct ChatInfoOptionsView: View {
    
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    @StateObject var viewModel: ChatChannelInfoViewModel
    
    public init(viewModel: ChatChannelInfoViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            if !viewModel.channel.isDirectMessageChannel {
                ChannelNameUpdateView(viewModel: viewModel)
            } else {
                ChatInfoMentionText(participant: viewModel.displayedParticipants.first)
            }

            Divider()

            ChannelInfoItemView(
                icon: images.muted,
                title: viewModel.mutedText,
                verticalPadding: 12
            ) {
                Toggle(isOn: $viewModel.muted) {
                    EmptyView()
                }
            }

            Divider()

            NavigatableChatInfoItemView(
                icon: images.pin,
                title: L10n.ChatInfo.PinnedMessages.title
            ) {
                PinnedMessagesView(
                    channel: viewModel.channel,
                    channelController: viewModel.channelController
                )
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

public struct ChannelNameUpdateView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    @StateObject var viewModel: ChatChannelInfoViewModel
    
    public init(viewModel: ChatChannelInfoViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        HStack(spacing: 16) {
            Text(L10n.ChatInfo.Rename.name)
                .font(fonts.footnote)
                .foregroundColor(Color(colors.textLowEmphasis))

            TextField(L10n.ChatInfo.Rename.placeholder, text: $viewModel.channelName)
                .font(fonts.body)
                .foregroundColor(Color(colors.text))
                .disabled(!viewModel.canRenameChannel)

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

public struct NavigatableChatInfoItemView<Destination: View>: View {
    let icon: UIImage
    let title: String
    var destination: () -> Destination
    
    public init(
        icon: UIImage,
        title: String,
        destination: @escaping () -> Destination
    ) {
        self.icon = icon
        self.title = title
        self.destination = destination
    }

    public var body: some View {
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

public struct ChannelInfoItemView<TrailingView: View>: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    let icon: UIImage
    let title: String
    var verticalPadding: CGFloat = 16
    var trailingView: () -> TrailingView
    
    public init(
        icon: UIImage,
        title: String,
        verticalPadding: CGFloat = 16,
        trailingView: @escaping () -> TrailingView
    ) {
        self.icon = icon
        self.title = title
        self.verticalPadding = verticalPadding
        self.trailingView = trailingView
    }

    public var body: some View {
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
        .padding(.horizontal)
        .padding(.vertical, verticalPadding)
        .background(Color(colors.background8))
    }
}

struct ChatInfoDirectChannelView: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var participant: ParticipantInfo?

    var body: some View {
        VStack {
            MessageAvatarView(
                avatarURL: participant?.chatUser.imageURL,
                size: .init(width: 64, height: 64)
            )

            Text(participant?.onlineInfoText ?? "")
                .font(fonts.footnote)
                .foregroundColor(Color(colors.textLowEmphasis))
        }
        .padding(.bottom)
    }
}

public struct ChatInfoMentionText: View {

    @Injected(\.colors) private var colors

    var participant: ParticipantInfo?
    
    public init(participant: ParticipantInfo? = nil) {
        self.participant = participant
    }

    public var body: some View {
        let mentionText = "@\(participant?.chatUser.mentionText ?? "")"
        ChannelInfoItemView(
            icon: UIImage(systemName: "person")!,
            title: mentionText
        ) {
            Button {
                UIPasteboard.general.string = mentionText
            } label: {
                Image(systemName: "doc.on.doc")
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
    }
}
