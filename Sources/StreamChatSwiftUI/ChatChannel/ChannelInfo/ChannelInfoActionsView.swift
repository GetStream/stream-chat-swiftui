//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The actions section shown at the bottom of the channel info screen.
///
/// Contains the mute conversation toggle, the block user button in one-on-one direct message
/// channels, the leave group button, and the delete channel button, with their confirmation alerts.
public struct ChannelInfoActionsView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    @ObservedObject private var viewModel: ChatChannelInfoViewModel

    private let leaveConversation: @MainActor () -> Void
    private let deleteChannel: @MainActor () -> Void

    public init(options: ChannelInfoActionsViewOptions) {
        viewModel = options.viewModel
        leaveConversation = options.leaveConversation
        deleteChannel = options.deleteChannel
    }

    public var body: some View {
        if viewModel.shouldShowActionsCard {
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

                if viewModel.shouldShowDeleteChannelButton {
                    deleteButton
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
        .modifier(ConfirmationAlertModifier(
            isPresented: $viewModel.blockUserAlertShown,
            confirmation: viewModel.blockUserConfirmation,
            onConfirm: viewModel.blockUserTapped
        ))
    }

    private var leaveButton: some View {
        destructiveActionButton(
            icon: viewModel.leaveButtonIcon,
            title: viewModel.leaveButtonTitle,
            isPresented: $viewModel.leaveGroupAlertShown,
            confirmation: viewModel.leaveConversationConfirmation,
            onConfirm: leaveConversation
        )
    }

    private var deleteButton: some View {
        destructiveActionButton(
            icon: images.trash,
            title: viewModel.deleteChannelTitle,
            isPresented: $viewModel.deleteChannelAlertShown,
            confirmation: viewModel.deleteChannelConfirmation,
            onConfirm: deleteChannel
        )
    }

    private func destructiveActionButton(
        icon: UIImage,
        title: String,
        isPresented: Binding<Bool>,
        confirmation: ConfirmationPopup,
        onConfirm: @escaping @MainActor () -> Void
    ) -> some View {
        Button {
            isPresented.wrappedValue = true
        } label: {
            HStack(spacing: tokens.spacingMd) {
                Image(uiImage: icon)
                    .customizable()
                    .frame(width: tokens.spacingLg)
                Text(title)
                Spacer()
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingMd)
            .font(fonts.body)
            .foregroundColor(Color(colors.accentError))
            .background(Color(colors.backgroundCoreSurfaceSubtle))
        }
        .modifier(ConfirmationAlertModifier(
            isPresented: isPresented,
            confirmation: confirmation,
            onConfirm: onConfirm
        ))
    }
}

// The `Alert` based API doesn't present on some devices (e.g. iPhone Duo), so the
// action based API is used where available.
private struct ConfirmationAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let confirmation: ConfirmationPopup
    let onConfirm: @MainActor () -> Void

    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content.alert(confirmation.title, isPresented: $isPresented) {
                Button(confirmation.buttonTitle, role: .destructive, action: onConfirm)
                Button(L10n.Alert.Actions.cancel, role: .cancel) {}
            } message: {
                if let message = confirmation.message {
                    Text(message)
                }
            }
        } else {
            content.alert(isPresented: $isPresented) {
                Alert(
                    title: Text(confirmation.title),
                    message: confirmation.message.map { Text($0) },
                    primaryButton: .destructive(Text(confirmation.buttonTitle)) {
                        onConfirm()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
