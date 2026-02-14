//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Background modifier for message reference views.
public struct ReferenceMessageViewBackgroundModifier: ViewModifier {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

    let isSentByCurrentUser: Bool

    init(isSentByCurrentUser: Bool) {
        self.isSentByCurrentUser = isSentByCurrentUser
    }

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(
                    cornerRadius: tokens.messageBubbleRadiusAttachment,
                    style: .continuous
                )
                .fill(Color(
                    isSentByCurrentUser
                        ? colors.chatBackgroundOutgoing
                        : colors.chatBackgroundIncoming
                ))
            )
    }
}
