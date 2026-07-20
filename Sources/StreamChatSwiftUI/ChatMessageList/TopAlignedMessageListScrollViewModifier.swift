//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct TopAlignedMessageListContentModifier: ViewModifier {
    var isEnabled: Bool
    var minimumHeight: CGFloat

    func body(content: Content) -> some View {
        content.frame(
            minHeight: isEnabled ? minimumHeight : nil,
            alignment: .bottom
        )
    }
}
