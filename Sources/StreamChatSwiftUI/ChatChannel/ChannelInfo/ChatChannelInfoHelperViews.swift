//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

// MARK: - Section Card Container

/// A rounded card container used to group related rows in the channel info screen.
public struct InfoSectionCard<Content: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
        }
        .clipShape(RoundedRectangle(cornerRadius: tokens.radiusLg))
    }
}

// MARK: - Group Header

/// Header view shown at the top of the group info screen.
/// Displays the channel avatar stack, channel name, and member count.
public struct ChatInfoGroupHeaderView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    let factory: Factory
    @ObservedObject var viewModel: ChatChannelInfoViewModel

    public init(factory: Factory = DefaultViewFactory.shared, viewModel: ChatChannelInfoViewModel) {
        self.factory = factory
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: tokens.spacingXs) {
            factory.makeChannelAvatarView(
                options: ChannelAvatarViewOptions(
                    channel: viewModel.channel,
                    size: AvatarSize.extraExtraLarge,
                    showsIndicator: false,
                    showsBorder: true
                )
            )
            Text(viewModel.channelName)
                .font(fonts.title3.weight(.semibold))
                .foregroundColor(Color(colors.textPrimary))

            let onlineCount = viewModel.participants.filter { $0.chatUser.isOnline }.count
            Text(L10n.Message.Title.group(viewModel.channel.memberCount, onlineCount))
                .font(fonts.footnote)
                .foregroundColor(Color(colors.textSecondary))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, tokens.spacingMd)
    }
}

// MARK: - DM Header

/// Header view shown at the top of the direct message info screen.
/// Displays the user avatar with online indicator, name, and online status.
public struct ChatInfoDirectMessageView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let participant: ParticipantInfo

    public init(factory: Factory = DefaultViewFactory.shared, participant: ParticipantInfo) {
        self.factory = factory
        self.participant = participant
    }

    public var body: some View {
        VStack(spacing: tokens.spacingXs) {
            factory.makeUserAvatarView(
                options: UserAvatarViewOptions(
                    user: participant.chatUser,
                    size: AvatarSize.extraExtraLarge,
                    showsIndicator: participant.chatUser.isOnline
                )
            )

            Text(participant.displayName)
                .font(fonts.title3.weight(.semibold))
                .foregroundColor(Color(colors.textPrimary))

            Text(participant.onlineInfoText)
                .font(fonts.footnote)
                .foregroundColor(Color(colors.textSecondary))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, tokens.spacingMd)
    }
}

// MARK: - Member Row

/// A single row in the members section of the group info screen.
/// Shows avatar, name, online status, and an admin badge when applicable.
public struct ChatInfoMemberView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let participant: ParticipantInfo
    var backgroundColor: UIColor?
    var onAppear: @MainActor () -> Void
    var onTap: @MainActor () -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        participant: ParticipantInfo,
        backgroundColor: UIColor? = nil,
        onAppear: @escaping @MainActor () -> Void,
        onTap: @escaping @MainActor () -> Void
    ) {
        self.factory = factory
        self.participant = participant
        self.backgroundColor = backgroundColor
        self.onAppear = onAppear
        self.onTap = onTap
    }

    public var body: some View {
        HStack(spacing: tokens.spacingSm) {
            factory.makeUserAvatarView(
                options: UserAvatarViewOptions(
                    user: participant.chatUser,
                    size: AvatarSize.medium,
                    showsIndicator: participant.chatUser.isOnline
                )
            )

            VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
                Text(participant.displayName)
                    .lineLimit(1)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.textPrimary))
                Text(participant.onlineInfoText)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textSecondary))
            }

            Spacer()

            if isAdminOrOwner {
                Text(L10n.ChatInfo.Member.admin)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textSecondary))
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingXs)
        .background(Color(backgroundColor ?? colors.backgroundCoreSurfaceSubtle))
        .contentShape(.rect)
        .onAppear { onAppear() }
        .onTapGesture { onTap() }
    }

    private var isAdminOrOwner: Bool {
        guard let member = participant.chatUser as? ChatChannelMember else { return false }
        return member.memberRole == .admin || member.memberRole == .owner || member.memberRole == .moderator
    }
}

// MARK: - Navigation Row

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
        Image(systemName: "chevron.forward")
            .foregroundColor(Color(colors.textSecondary))
    }
}

// MARK: - Item Row

public struct ChannelInfoItemView<TrailingView: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let icon: UIImage
    let title: String
    var trailingView: () -> TrailingView

    public init(
        icon: UIImage,
        title: String,
        trailingView: @escaping () -> TrailingView
    ) {
        self.icon = icon
        self.title = title
        self.trailingView = trailingView
    }

    public var body: some View {
        HStack(spacing: tokens.spacingMd) {
            Image(uiImage: icon)
                .customizable()
                .frame(width: tokens.spacingLg)
                .foregroundColor(Color(colors.textSecondary))

            Text(title)
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))

            Spacer()

            trailingView()
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingMd)
        .background(Color(colors.backgroundCoreSurfaceSubtle))
    }
}

public final class ParticipantInfo: Identifiable {
    public var id: String {
        chatUser.id
    }

    public let chatUser: ChatUser
    public let displayName: String
    public let onlineInfoText: String
    public let isDeactivated: Bool

    public init(
        chatUser: ChatUser,
        displayName: String,
        onlineInfoText: String,
        isDeactivated: Bool = false
    ) {
        self.chatUser = chatUser
        self.displayName = displayName
        self.onlineInfoText = onlineInfoText
        self.isDeactivated = isDeactivated
    }
}
