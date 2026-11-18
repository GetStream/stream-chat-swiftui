//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Shows an alert asking to confirm a destructive action.
///
/// The `Alert` based API doesn't present on some devices (e.g. iPhone Duo), so the
/// action based API is used where available.
struct ConfirmationAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let confirmation: ConfirmationPopup
    let onConfirm: @MainActor () -> Void

    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content.alert(confirmation.title, isPresented: $isPresented) {
                Button(confirmation.buttonTitle, role: .destructive, action: onConfirm)
                Button(L10n.Alert.Actions.cancel, role: .cancel) {}
            } message: {
                if let message = confirmation.message {
                    Text(message)
                }
            }
        } else {
            content.alert(isPresented: $isPresented) {
                Alert(
                    title: Text(confirmation.title),
                    message: confirmation.message.map { Text($0) },
                    primaryButton: .destructive(Text(confirmation.buttonTitle)) {
                        onConfirm()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
