//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The button for sending messages.
public struct SendMessageButton: View {
    @Environment(\.layoutDirection) private var layoutDirection

    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    var enabled: Bool
    var onTap: () -> Void
    var onLongPress: (() -> Void)?

    // The button also fires its action when a long press is released, which is skipped.
    @State private var skipsNextTap = false
    @GestureState private var isPressing = false

    public init(
        enabled: Bool,
        onTap: @escaping () -> Void,
        onLongPress: (() -> Void)? = nil
    ) {
        self.enabled = enabled
        self.onTap = onTap
        self.onLongPress = onLongPress
    }

    public var body: some View {
        StreamIconButton(
            role: .primary,
            style: .solid,
            size: .small,
            action: {
                if skipsNextTap {
                    skipsNextTap = false
                } else {
                    onTap()
                }
            }
        ) {
            Image(uiImage: images.composerSend)
                .renderingMode(.template)
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .scaleEffect(x: layoutDirection == .rightToLeft ? -1 : 1, y: 1)
        }
        .simultaneousGesture(longPressGesture, including: enabled && onLongPress != nil ? .all : .subviews)
        .onChange(of: isPressing) { isPressing in
            // A release that never reaches the button, such as a cancelled touch, must not skip the next tap.
            if isPressing {
                skipsNextTap = false
            }
        }
        // Assistive activation doesn't go through the touch handling above.
        .accessibilityAction { onTap() }
        .modifier(ScheduleMessageAccessibilityAction(action: onLongPress))
        .disabled(!enabled)
        .accessibilityLabel(Text(L10n.Composer.Placeholder.message))
        .accessibilityIdentifier("SendMessageButton")
    }

    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .updating($isPressing) { value, state, _ in
                state = value
            }
            .onEnded { _ in
                skipsNextTap = true
                triggerHapticFeedback(style: .medium)
                onLongPress?()
            }
    }
}

// VoiceOver can't long press, so scheduling is also a named action.
private struct ScheduleMessageAccessibilityAction: ViewModifier {
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            // The condition is inside the actions, which keeps the identity of the button.
            content.accessibilityActions {
                if let action {
                    Button(L10n.Composer.ScheduleMessage.title, action: action)
                }
            }
        } else if let action {
            content.accessibilityAction(named: Text(L10n.Composer.ScheduleMessage.title), action)
        } else {
            content
        }
    }
}

@available(iOS 15, *)
#Preview {
    HStack(spacing: 16) {
        VStack {
            Section("Light") {
                SendMessageButton(
                    enabled: true,
                    onTap: {}
                )

                SendMessageButton(
                    enabled: false,
                    onTap: {}
                )
            }
        }
        .padding()
        .frame(width: 120)

        VStack {
            Text("Dark")
            SendMessageButton(
                enabled: true,
                onTap: {}
            )

            SendMessageButton(
                enabled: false,
                onTap: {}
            )
        }
        .padding()
        .frame(width: 120)
        .colorScheme(.dark)
        .background(Color.black)
    }
}
