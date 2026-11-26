//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct LongPressButton<Label: View>: View {
    @Environment(\.isEnabled) private var isEnabled

    // The button also fires its action when a long press is released, which is skipped.
    @State private var skipsNextTap = false
    @GestureState private var isPressing = false

    private let action: () -> Void
    private let longPressAction: (() -> Void)?
    private let longPressActionName: String
    private let label: Label

    init(
        action: @escaping () -> Void,
        longPressAction: (() -> Void)?,
        longPressActionName: String,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.longPressAction = longPressAction
        self.longPressActionName = longPressActionName
        self.label = label()
    }

    var body: some View {
        Button(
            action: {
                if skipsNextTap {
                    skipsNextTap = false
                } else {
                    action()
                }
            },
            label: { label }
        )
        .simultaneousGesture(longPressGesture, including: isEnabled && longPressAction != nil ? .all : .subviews)
        .onChange(of: isPressing) { isPressing in
            // A release that never reaches the button, such as a cancelled touch, must not skip the next tap.
            if isPressing {
                skipsNextTap = false
            }
        }
        // Assistive activation doesn't go through the touch handling above.
        .accessibilityAction { action() }
        .modifier(LongPressAccessibilityAction(name: longPressActionName, action: isEnabled ? longPressAction : nil))
    }

    private var longPressGesture: some Gesture {
        LongPressGesture()
            .updating($isPressing) { value, state, _ in
                state = value
            }
            .onEnded { _ in
                skipsNextTap = true
                triggerHapticFeedback(style: .medium)
                longPressAction?()
            }
    }
}

// VoiceOver can't long press, so the long press is also a named action.
private struct LongPressAccessibilityAction: ViewModifier {
    let name: String
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            // The condition is inside the actions, which keeps the identity of the button.
            content.accessibilityActions {
                if let action {
                    Button(name, action: action)
                }
            }
        } else if let action {
            content.accessibilityAction(named: Text(name), action)
        } else {
            content
        }
    }
}
