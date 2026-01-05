//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension View {
    /// Returns the bottom safe area of the device.
    public var bottomSafeArea: CGFloat {
        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        return bottomPadding
    }

    public var topSafeArea: CGFloat {
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        return topPadding
    }
}

extension Alert {
    public static var defaultErrorAlert: Alert {
        Alert(
            title: Text(L10n.Alert.Error.title),
            message: Text(L10n.Alert.Error.message),
            dismissButton: .cancel(Text(L10n.Alert.Actions.ok))
        )
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Method for making a haptic feedback.
    /// - Parameter style: feedback style
    func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
