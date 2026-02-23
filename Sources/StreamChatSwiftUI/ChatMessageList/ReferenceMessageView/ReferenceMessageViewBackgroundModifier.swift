//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Background modifier for message reference views.
public struct ReferenceMessageViewBackgroundModifier: ViewModifier {
    @Injected(\.tokens) var tokens

    let backgroundColor: Color

    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(
                    cornerRadius: tokens.messageBubbleRadiusAttachment,
                    style: .continuous
                )
                .fill(backgroundColor)
            )
    }
}
