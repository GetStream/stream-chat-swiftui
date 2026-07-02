//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension Compatibility where Content: View {
    /// Applies `scrollBounceBehavior(.basedOnSize)` where available, so the
    /// scroll view only bounces/scrolls once its content overflows.
    @ViewBuilder
    func scrollBounceBehaviorBasedOnSize() -> some View {
        if #available(iOS 16.4, *) {
            content.scrollBounceBehavior(.basedOnSize)
        } else {
            content
        }
    }
}
