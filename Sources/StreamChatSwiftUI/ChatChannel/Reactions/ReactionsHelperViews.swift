//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ReactionsHStack<Content: View>: View {
    var message: ChatMessage
    var content: () -> Content

    public init(message: ChatMessage, content: @escaping () -> Content) {
        self.message = message
        self.content = content
    }

    public var body: some View {
        HStack {
            if !message.isRightAligned {
                Spacer()
            }

            content()

            if message.isRightAligned {
                Spacer()
            }
        }
    }
}
