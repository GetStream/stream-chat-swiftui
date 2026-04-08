//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default view for the channel more actions view.
public struct MoreChannelActionsView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.chatClient) private var chatClient

    @StateObject var viewModel: MoreChannelActionsViewModel
    @Binding var swipedChannelId: String?
    @State private var isPresented = false
    var bundle: Bundle?
    var onDismiss: () -> Void

    @State private var presentedView: AnyView? {
        didSet {
            isPresented = presentedView != nil
        }
    }

    private let channel: ChatChannel
    public let factory: Factory

    public init(
        factory: Factory,
        channel: ChatChannel,
        channelActions: [ChannelAction],
        swipedChannelId: Binding<String?>,
        bundle: Bundle? = nil,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeMoreChannelActionsViewModel(
                channel: channel,
                actions: channelActions
            )
        )
        self.factory = factory
        self.channel = channel
        self.onDismiss = onDismiss
        _swipedChannelId = swipedChannelId
        self.bundle = bundle
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                channelHeader
                actionsListView
                Spacer()
            }
        }
        .background(colors.backgroundCoreElevation1.toColor.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $viewModel.alertShown) {
            let title = viewModel.alertAction?.confirmationPopup?.title ?? ""
            let message = viewModel.alertAction?.confirmationPopup?.message ?? ""
            let buttonTitle = viewModel.alertAction?.confirmationPopup?.buttonTitle ?? ""

            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .destructive(Text(buttonTitle)) {
                    viewModel.alertAction?.action()
                },
                secondaryButton: .cancel()
            )
        }
        .fullScreenCover(isPresented: $isPresented) {
            if let fullScreenView = presentedView {
                MoreChannelActionsFullScreenWrappingView(presentedView: fullScreenView) {
                    presentedView = nil
                }
            }
        }
        .accessibilityIdentifier("MoreChannelActionsView")
    }

    private var channelHeader: some View {
        HStack(spacing: tokens.spacingMd) {
            headerAvatar
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
                Text(viewModel.chatName)
                    .font(fonts.headline)
                    .foregroundColor(Color(colors.textPrimary))

                if !viewModel.subtitleText.isEmpty {
                    Text(viewModel.subtitleText)
                        .font(fonts.subheadline)
                        .foregroundColor(Color(colors.textTertiary))
                }
            }

            Spacer()
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingLg)
        .padding(.top, tokens.spacingXxs)
    }

    @ViewBuilder
    private var headerAvatar: some View {
        if channel.isDirectMessageChannel,
           let otherMember = viewModel.members.first(where: { $0.id != chatClient.currentUserId }) {
            factory.makeUserAvatarView(
                options: UserAvatarViewOptions(
                    user: otherMember,
                    size: AvatarSize.large,
                    showsIndicator: otherMember.isOnline
                )
            )
        } else {
            factory.makeChannelAvatarView(
                options: ChannelAvatarViewOptions(
                    channel: channel,
                    size: AvatarSize.large,
                    showsIndicator: false,
                    showsBorder: false
                )
            )
        }
    }

    private var actionsListView: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.channelActions) { action in
                if let destination = action.navigationDestination {
                    Button {
                        presentedView = destination
                    } label: {
                        ActionItemView(
                            title: action.title,
                            iconName: action.iconName,
                            isDestructive: action.isDestructive,
                            boldTitle: false,
                            bundle: bundle
                        )
                        .padding(.horizontal, tokens.spacingMd)
                    }
                } else {
                    Button {
                        if action.confirmationPopup != nil {
                            viewModel.alertAction = action
                        } else {
                            action.action()
                        }
                    } label: {
                        ActionItemView(
                            title: action.title,
                            iconName: action.iconName,
                            isDestructive: action.isDestructive,
                            boldTitle: false,
                            bundle: bundle
                        )
                        .padding(.horizontal, tokens.spacingMd)
                    }
                }
            }
        }
        .foregroundColor(Color(colors.textPrimary))
    }
}
