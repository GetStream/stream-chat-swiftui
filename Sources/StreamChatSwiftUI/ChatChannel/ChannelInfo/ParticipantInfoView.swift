//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ParticipantInfoView<Factory: ViewFactory>: View {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    var factory: Factory
    let participant: ParticipantInfo
    var actions: [ParticipantAction]
    
    var onDismiss: () -> Void
    
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
    
    @State private var alertShown = false
    @State private var alertAction: ParticipantAction? {
        didSet {
            alertShown = alertAction != nil
        }
    }
    
    public var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 4) {
                Text(participant.displayName)
                    .font(fonts.bodyBold)

                Text(participant.onlineInfoText)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
                
                let displayInfo = UserDisplayInfo(
                    id: participant.chatUser.id,
                    name: participant.chatUser.name ?? participant.chatUser.id,
                    imageURL: participant.chatUser.imageURL,
                    size: CGSize(width: 64, height: 64)
                )
                factory.makeMessageAvatarView(for: displayInfo)
                    .padding()

                VStack {
                    ForEach(actions) { action in
                        Divider()
                            .padding(.horizontal, -16)

                        if let destination = action.navigationDestination {
                            NavigationLink {
                                destination
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
                                    alertAction = action
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
            .frame(maxWidth: .infinity)
            .background(Color(colors.background1))
            .cornerRadius(16)
            .padding(.all, 8)
            .foregroundColor(Color(colors.text))
            .opacity(alertShown ? 0 : 1)
        }
        .alert(isPresented: $alertShown) {
            Alert(
                title: Text(alertAction?.confirmationPopup?.title ?? ""),
                message: Text(alertAction?.confirmationPopup?.message ?? ""),
                primaryButton: .destructive(Text(alertAction?.confirmationPopup?.buttonTitle ?? "")) {
                    alertAction?.action()
                },
                secondaryButton: .cancel()
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect)
        .onTapGesture {
            onDismiss()
        }
    }
}

/// Model describing a participant action.
public struct ParticipantAction: Identifiable {
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
