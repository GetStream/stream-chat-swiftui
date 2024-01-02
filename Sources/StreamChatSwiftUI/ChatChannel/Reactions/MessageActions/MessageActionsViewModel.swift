//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View model for the `MessageActionsView`.
open class MessageActionsViewModel: ObservableObject {
    @Published public var messageActions: [MessageAction]
    @Published public var alertShown = false
    @Published public var alertAction: MessageAction? {
        didSet {
            alertShown = alertAction != nil
        }
    }

    public init(messageActions: [MessageAction]) {
        self.messageActions = messageActions
    }
}

/// Model describing a message action.
public struct MessageAction: Identifiable, Equatable {
    public var id: String

    public let title: String
    public let iconName: String
    public let action: () -> Void
    public let confirmationPopup: ConfirmationPopup?
    public let isDestructive: Bool
    public var navigationDestination: AnyView?

    public init(
        id: String = UUID().uuidString,
        title: String,
        iconName: String,
        action: @escaping () -> Void,
        confirmationPopup: ConfirmationPopup?,
        isDestructive: Bool
    ) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.action = action
        self.confirmationPopup = confirmationPopup
        self.isDestructive = isDestructive
    }

    public static func == (lhs: MessageAction, rhs: MessageAction) -> Bool {
        lhs.id == rhs.id
    }
}

/// Provides information about a performed `MessageAction`.
public struct MessageActionInfo {
    public let message: ChatMessage
    public let identifier: String

    public init(message: ChatMessage, identifier: String) {
        self.message = message
        self.identifier = identifier
    }
}
