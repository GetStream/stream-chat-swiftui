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

    @StateObject var viewModel: MoreChannelActionsViewModel
    @Binding var swipedChannelId: String?
    @State private var isPresented = false
    var onDismiss: () -> Void

    @State private var presentedView: AnyView? {
        didSet {
            isPresented = presentedView != nil
        }
    }
    
    public let factory: Factory

    public init(
        factory: Factory,
        channel: ChatChannel,
        channelActions: [ChannelAction],
        swipedChannelId: Binding<String?>,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeMoreChannelActionsViewModel(
                channel: channel,
                actions: channelActions
            )
        )
        self.factory = factory
        self.onDismiss = onDismiss
        _swipedChannelId = swipedChannelId
    }

    public var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 4) {
                Text(viewModel.chatName)
                    .font(fonts.bodyBold)

                Text(viewModel.subtitleText)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))

                memberList

                ForEach(viewModel.channelActions) { action in
                    VStack {
                        Divider()
                            .padding(.horizontal, -16)

                        if let destination = action.navigationDestination {
                            Button {
                                presentedView = destination
                            } label: {
                                ActionItemView(
                                    title: action.title,
                                    iconName: action.iconName,
                                    isDestructive: action.isDestructive
                                )
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
                                    isDestructive: action.isDestructive
                                )
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(colors.background1))
            .cornerRadius(16)
            .padding(.all, 8)
            .padding(.bottom, bottomSafeArea)
            .foregroundColor(Color(colors.text))
            .opacity(viewModel.alertShown ? 0 : 1)
        }
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
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            onDismiss()
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

    private var memberList: some View {
        Group {
            if viewModel.members.count == 1 {
                let member = viewModel.members[0]
                ChannelMemberView(
                    factory: factory,
                    userDisplayInfo: UserDisplayInfo(member: member)
                )
            } else {
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(viewModel.members) { member in
                            ChannelMemberView(
                                factory: factory,
                                userDisplayInfo: UserDisplayInfo(member: member)
                            )
                        }
                    }
                }
            }
        }
        .padding(.vertical, 16)
    }
}

/// View displaying channel members with image and name.
public struct ChannelMemberView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts

    let factory: Factory
    let userDisplayInfo: UserDisplayInfo
    let memberSize = CGSize(width: 64, height: 64)

    public var body: some View {
        VStack(alignment: .center) {
            factory.makeUserAvatarView(
                options: UserAvatarViewOptions(
                    userDisplayInfo: userDisplayInfo,
                    size: AvatarSize.large,
                    indicator: false
                )
            )
            .accessibilityHidden(true)

            Text(userDisplayInfo.name)
                .font(fonts.footnoteBold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: memberSize.width, maxHeight: 34, alignment: .top)
                .accessibilityLabel(Text(accessibilityLabel))
        }
    }
    
    var accessibilityLabel: String {
        userDisplayInfo.name + (userDisplayInfo.isOnline ? ", \(L10n.Message.Title.online)" : "")
    }
}
