//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI
import UIKit

extension View {
    /// Returns VoiceOver focus to this view when the presentation binding
    /// flips from `true` to `false`.
    ///
    /// Native modal/sheet dismissal sometimes leaves VoiceOver focus orphaned
    /// on a stale element (commonly the back button or the channel header)
    /// instead of returning it to the originating element. This modifier
    /// keeps a small delay so the dismissal animation can settle before
    /// VoiceOver moves focus.
    ///
    /// Uses `@AccessibilityFocusState` on iOS 15+. On iOS 14 it falls back
    /// to a `screenChanged` notification so VoiceOver at least re-picks a
    /// focusable element on the current screen.
    @ViewBuilder
    func restoresAccessibilityFocusOnDismiss(of isPresented: Binding<Bool>) -> some View {
        if #available(iOS 15.0, *) {
            modifier(RestoresAccessibilityFocusOnDismissModifier(isPresented: isPresented))
        } else {
            onChange(of: isPresented.wrappedValue) { isShown in
                guard !isShown else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIAccessibility.post(notification: .screenChanged, argument: nil)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
private struct RestoresAccessibilityFocusOnDismissModifier: ViewModifier {
    @Binding var isPresented: Bool
    @AccessibilityFocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .accessibilityFocused($isFocused)
            .onChange(of: isPresented) { isShown in
                guard !isShown else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
    }
}
