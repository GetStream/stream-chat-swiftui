//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ParticipantInfoView<Factory: ViewFactory>: View {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

    var factory: Factory
    let participant: ParticipantInfo
    var actions: [ParticipantAction]
    var onDismiss: () -> Void

    @State private var alertShown = false
    @State private var alertAction: ParticipantAction? {
        didSet { alertShown = alertAction != nil }
    }

    init(
        factory: Factory = DefaultViewFactory.shared,
        participant: ParticipantInfo,
        actions: [ParticipantAction],
        onDismiss: @escaping () -> Void
    ) {
        self.factory = factory
        self.participant = participant
        self.actions = actions
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: tokens.spacingMd) {
                        factory.makeUserAvatarView(
                            options: .init(
                                user: participant.chatUser,
                                size: AvatarSize.extraLarge,
                                showsIndicator: true
                            )
                        )
                        .padding(.top, tokens.spacingSm)
                        
                        VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
                            Text(participant.displayName)
                                .font(fonts.title3.weight(.semibold))
                                .foregroundColor(Color(colors.textPrimary))
                            Text(participant.onlineInfoText)
                                .font(fonts.footnote)
                                .foregroundColor(Color(colors.textSecondary))
                        }
                        Spacer()
                    }
                    .padding(.all, tokens.spacingMd)

                    ForEach(actions) { action in
                        actionRow(for: action)
                    }

                    Spacer()
                }
            }
            .background(Color(colors.background).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
        .alert(isPresented: $alertShown) {
            Alert(
                title: Text(alertAction?.confirmationPopup?.title ?? ""),
                message: Text(alertAction?.confirmationPopup?.message ?? ""),
                primaryButton: .destructive(Text(alertAction?.confirmationPopup?.buttonTitle ?? "")) {
                    alertAction?.action()
                    onDismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }

    @ViewBuilder
    private func actionRow(for action: ParticipantAction) -> some View {
        if let destination = action.navigationDestination {
            NavigationLink {
                destination
            } label: {
                actionLabel(for: action)
            }
        } else {
            Button {
                if action.confirmationPopup != nil {
                    alertAction = action
                } else {
                    action.action()
                    onDismiss()
                }
            } label: {
                actionLabel(for: action)
            }
        }
    }

    private func actionLabel(for action: ParticipantAction) -> some View {
        HStack(spacing: tokens.spacingMd) {
            Image(systemName: action.iconName)
                .frame(width: tokens.spacingLg)
            Text(action.title)
                .font(fonts.body)
            Spacer()
        }
        .foregroundColor(action.isDestructive ? Color(colors.alert) : Color(colors.textPrimary))
        .padding(.all, tokens.spacingMd)
    }
}

/// Model describing a participant action.
public final class ParticipantAction: Identifiable {
    public var id: String {
        "\(title)-\(iconName)"
    }

    public let title: String
    public let iconName: String
    public let action: () -> Void
    public let confirmationPopup: ConfirmationPopup?
    public let isDestructive: Bool
    public var navigationDestination: AnyView?

    public init(
        title: String,
        iconName: String,
        action: @escaping () -> Void,
        confirmationPopup: ConfirmationPopup?,
        isDestructive: Bool
    ) {
        self.title = title
        self.iconName = iconName
        self.action = action
        self.confirmationPopup = confirmationPopup
        self.isDestructive = isDestructive
    }
}
