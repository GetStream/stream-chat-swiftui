//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View model for the `MessageActionsView`.
public class MessageActionsViewModel: ObservableObject {
    @Published var messageActions: [MessageAction]
    @Published var alertShown = false
    @Published var alertAction: MessageAction? {
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
    public var id: String {
        "\(title)-\(iconName)"
    }

    public let title: String
    public let iconName: String
    public let action: () -> Void
    public let confirmationPopup: ConfirmationPopup?
    public let isDestructive: Bool
    
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
    
    public static func == (lhs: MessageAction, rhs: MessageAction) -> Bool {
        lhs.id == rhs.id
    }
}
