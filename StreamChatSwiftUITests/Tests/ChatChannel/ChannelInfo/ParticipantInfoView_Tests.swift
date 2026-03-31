//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class ParticipantInfoView_Tests: StreamChatTestCase {
    func test_participantInfoView_withBasicActionsSnapshot() {
        // Given
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique, name: "John Doe", isOnline: true),
            displayName: "John Doe",
            onlineInfoText: L10n.Message.Title.online,
            isDeactivated: false
        )
        let actions: [ParticipantAction] = [
            ParticipantAction(
                title: L10n.Channel.Item.sendDirectMessage,
                iconName: "message",
                action: {},
                confirmationPopup: nil,
                isDestructive: false
            ),
            ParticipantAction(
                title: L10n.Alert.Actions.blockUser,
                iconName: "nosign",
                action: {},
                confirmationPopup: nil,
                isDestructive: false
            )
        ]

        // When
        let view = ParticipantInfoView(
            participant: participant,
            actions: actions,
            onDismiss: {}
        ).applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_participantInfoView_withDestructiveActionSnapshot() {
        // Given
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique, name: "Jane Smith", isOnline: false),
            displayName: "Jane Smith",
            onlineInfoText: L10n.Message.Title.offline,
            isDeactivated: false
        )
        let actions: [ParticipantAction] = [
            ParticipantAction(
                title: L10n.Alert.Actions.blockUser,
                iconName: "nosign",
                action: {},
                confirmationPopup: nil,
                isDestructive: false
            ),
            ParticipantAction(
                title: L10n.Channel.Item.removeUser,
                iconName: "person.slash",
                action: {},
                confirmationPopup: ConfirmationPopup(
                    title: L10n.Channel.Item.removeUserConfirmationTitle,
                    message: L10n.Channel.Item.removeUserConfirmationMessage("Jane Smith", "Test Channel"),
                    buttonTitle: L10n.Channel.Item.removeUser
                ),
                isDestructive: true
            )
        ]

        // When
        let view = ParticipantInfoView(
            participant: participant,
            actions: actions,
            onDismiss: {}
        ).applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_participantInfoView_emptyActionsSnapshot() {
        // Given - current user in 1-on-1 DM has no actions
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique, name: "Current User", isOnline: true),
            displayName: L10n.Channel.Item.you,
            onlineInfoText: L10n.Message.Title.online,
            isDeactivated: false
        )

        // When
        let view = ParticipantInfoView(
            participant: participant,
            actions: [],
            onDismiss: {}
        ).applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_participantInfoView_withLeaveGroupActionSnapshot() {
        // Given - current user in a group sees leave group action
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique, name: "Current User", isOnline: true),
            displayName: L10n.Channel.Item.you,
            onlineInfoText: L10n.Message.Title.online,
            isDeactivated: false
        )
        let actions: [ParticipantAction] = [
            ParticipantAction(
                title: L10n.Alert.Actions.leaveGroupTitle,
                iconName: "rectangle.portrait.and.arrow.right",
                action: {},
                confirmationPopup: ConfirmationPopup(
                    title: L10n.Alert.Actions.leaveGroupTitle,
                    message: L10n.Alert.Actions.leaveGroupMessage,
                    buttonTitle: L10n.Alert.Actions.leaveGroupButton
                ),
                isDestructive: true
            )
        ]

        // When
        let view = ParticipantInfoView(
            participant: participant,
            actions: actions,
            onDismiss: {}
        ).applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
}
