//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The actions section shown at the bottom of the channel info screen.
///
/// Contains the mute conversation toggle, the block user button in direct message channels,
/// and the leave group / delete conversation button, together with their confirmation alerts.
public struct ChannelInfoActionsView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    @ObservedObject private var viewModel: ChatChannelInfoViewModel

    private let leaveConversation: @MainActor () -> Void

    private enum AlertType: Identifiable {
        case blockUser, leaveConversation
        var id: Self { self }
    }

    @State private var alertType: AlertType?

    public init(options: ChannelInfoActionsViewOptions) {
        viewModel = options.viewModel
        leaveConversation = options.leaveConversation
    }

    public var body: some View {
        if viewModel.shouldShowMuteChannelButton
            || viewModel.shouldShowBlockUserButton
            || viewModel.shouldShowLeaveConversationButton {
            InfoSectionCard {
                if viewModel.shouldShowMuteChannelButton {
                    ChannelInfoItemView(
                        icon: images.muted,
                        title: viewModel.mutedText
                    ) {
                        Toggle(isOn: $viewModel.muted) {
                            EmptyView()
                        }
                    }
                }

                if viewModel.shouldShowBlockUserButton {
                    blockButton
                }

                if viewModel.shouldShowLeaveConversationButton {
                    leaveButton
                }
            }
            .alert(item: $alertType) { type -> Alert in
                switch type {
                case .blockUser:
                    return Alert(
                        title: Text(viewModel.blockUserTitle),
                        message: Text(
                            viewModel.isDMUserBlocked
                                ? L10n.Message.Actions.UserUnblock.confirmationMessage
                                : L10n.Message.Actions.UserBlock.confirmationMessage
                        ),
                        primaryButton: .destructive(Text(viewModel.blockUserTitle)) {
                            viewModel.blockUserTapped()
                        },
                        secondaryButton: .cancel()
                    )
                case .leaveConversation:
                    return Alert(
                        title: Text(viewModel.leaveButtonTitle),
                        message: Text(viewModel.leaveConversationDescription),
                        primaryButton: .destructive(Text(viewModel.leaveButtonTitle)) {
                            leaveConversation()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }

    private var blockButton: some View {
        Button {
            alertType = .blockUser
        } label: {
            HStack(spacing: tokens.spacingMd) {
                Image(uiImage: images.messageActionBlockUser)
                    .customizable()
                    .frame(width: tokens.spacingLg)
                Text(viewModel.blockUserTitle)
                Spacer()
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingMd)
            .font(fonts.body)
            .foregroundColor(Color(colors.textPrimary))
            .background(Color(colors.backgroundCoreSurfaceSubtle))
        }
    }

    private var leaveButton: some View {
        Button {
            alertType = .leaveConversation
        } label: {
            HStack(spacing: tokens.spacingMd) {
                Image(systemName: viewModel.showSingleMemberDMView ? "trash" : "rectangle.portrait.and.arrow.right")
                    .customizable()
                    .frame(width: tokens.spacingLg)
                Text(viewModel.leaveButtonTitle)
                Spacer()
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingMd)
            .font(fonts.body)
            .foregroundColor(Color(colors.accentError))
            .background(Color(colors.backgroundCoreSurfaceSubtle))
        }
    }
}
