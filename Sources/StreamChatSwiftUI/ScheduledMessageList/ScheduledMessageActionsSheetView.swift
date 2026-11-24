//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The sheet with the actions of a scheduled message.
public struct ScheduledMessageActionsSheetView: View {
    @Injected(\.tokens) private var tokens

    private let actions: [ScheduledMessageListAction]
    private let onDismiss: @MainActor () -> Void

    /// Creates the sheet.
    /// - Parameters:
    ///   - actions: The actions of the scheduled message.
    ///   - onDismiss: Called when the close button is tapped. The sheet only has one before iOS 16, where it covers
    ///   the screen.
    public init(
        actions: [ScheduledMessageListAction],
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.actions = actions
        self.onDismiss = onDismiss
    }

    public var body: some View {
        SheetView(
            title: nil,
            estimatedContentHeight: CGFloat(actions.count) * tokens.buttonHitTargetMinHeight,
            onClose: onDismiss
        ) {
            ForEach(actions) { action in
                Button(action: action.action) {
                    ListItemView(icon: action.icon, title: action.title, destructive: action.isDestructive)
                }
                .buttonStyle(ListItemButtonStyle())
                .accessibilityIdentifier("ScheduledMessageListAction-\(action.id)")
            }
        }
        .accessibilityIdentifier("ScheduledMessageActionsSheetView")
    }
}
