//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default view for the channel more actions view.
public struct MoreChannelActionsView: View {
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

    public init(
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
                    avatar: viewModel.image(for: member),
                    name: member.name ?? member.id,
                    onlineIndicatorShown: member.isOnline
                )
            } else {
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(viewModel.members) { member in
                            ChannelMemberView(
                                avatar: viewModel.image(for: member),
                                name: member.name ?? member.id,
                                onlineIndicatorShown: member.isOnline
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
public struct ChannelMemberView: View {
    @Injected(\.fonts) private var fonts

    let avatar: UIImage
    let name: String
    let onlineIndicatorShown: Bool

    let memberSize = CGSize(width: 64, height: 64)

    public var body: some View {
        VStack(alignment: .center) {
            ChannelAvatarView(
                avatar: avatar,
                showOnlineIndicator: onlineIndicatorShown,
                size: memberSize
            )

            Text(name)
                .font(fonts.footnoteBold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: memberSize.width, maxHeight: 34, alignment: .top)
        }
    }
}
