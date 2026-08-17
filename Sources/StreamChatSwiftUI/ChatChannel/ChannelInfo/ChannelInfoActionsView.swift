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
        }
    }

    private var blockButton: some View {
        Button {
            viewModel.blockUserAlertShown = true
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
        .alert(isPresented: $viewModel.blockUserAlertShown) {
            confirmationAlert(for: viewModel.blockUserConfirmation) {
                viewModel.blockUserTapped()
            }
        }
    }

    private var leaveButton: some View {
        Button {
            viewModel.leaveGroupAlertShown = true
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
        .alert(isPresented: $viewModel.leaveGroupAlertShown) {
            confirmationAlert(for: viewModel.leaveConversationConfirmation) {
                leaveConversation()
            }
        }
    }

    private func confirmationAlert(
        for confirmation: ConfirmationPopup,
        action: @escaping @MainActor () -> Void
    ) -> Alert {
        Alert(
            title: Text(confirmation.title),
            message: confirmation.message.map { Text($0) },
            primaryButton: .destructive(Text(confirmation.buttonTitle), action: action),
            secondaryButton: .cancel()
        )
    }
}
