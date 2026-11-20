//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension Compatibility where Content: View {
    func presentationDragIndicatorVisible() -> some View {
        content.modifier(PresentationDragIndicatorVisibleModifier())
    }
}

private struct PresentationDragIndicatorVisibleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}
