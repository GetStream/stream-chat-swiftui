//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The sheet for picking when to send a scheduled message.
public struct ScheduleMessageSheetView: View {
    @Injected(\.tokens) private var tokens

    private let actions: [ScheduleMessageAction]
    private let reachedLimit: Int?
    private let onDismiss: @MainActor () -> Void

    /// Creates the sheet.
    /// - Parameters:
    ///   - actions: The actions to pick from.
    ///   - reachedLimit: The limit of scheduled messages that was reached. The actions are disabled when it is set.
    ///   - onDismiss: Called when the close button is tapped.
    public init(
        actions: [ScheduleMessageAction],
        reachedLimit: Int?,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.actions = actions
        self.reachedLimit = reachedLimit
        self.onDismiss = onDismiss
    }

    public var body: some View {
        SheetView(
            title: title,
            estimatedContentHeight: CGFloat(actions.count) * tokens.buttonHitTargetMinHeight,
            onClose: onDismiss
        ) {
            ForEach(actions) { action in
                Button(action: action.action) {
                    ListItemView(
                        icon: action.icon,
                        title: action.title,
                        showsChevron: action.showsChevron
                    )
                }
                .accessibilityIdentifier("ScheduleMessageAction-\(action.id)")
            }
            .disabled(reachedLimit != nil)
            .opacity(reachedLimit == nil ? 1 : 0.4)
        }
        .accessibilityIdentifier("ScheduleMessageSheetView")
    }

    private var title: String {
        if let reachedLimit {
            L10n.Composer.ScheduleMessage.limitReached(reachedLimit)
        } else {
            L10n.Composer.ScheduleMessage.title
        }
    }
}
