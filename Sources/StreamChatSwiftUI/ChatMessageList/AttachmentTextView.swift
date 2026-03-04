//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct AttachmentTextView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var message: ChatMessage
    let injectedBackgroundColor: UIColor?

    public init(factory: Factory = DefaultViewFactory.shared, message: ChatMessage, injectedBackgroundColor: UIColor? = nil) {
        self.factory = factory
        self.message = message
        self.injectedBackgroundColor = injectedBackgroundColor
    }

    public var body: some View {
        HStack {
            factory.makeAttachmentTextView(options: .init(mesage: message))
                .padding(.horizontal, tokens.spacingXxs)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .background(Color(backgroundColor))
        .accessibilityIdentifier("AttachmentTextView")
    }

    private var backgroundColor: UIColor {
        if let injectedBackgroundColor {
            return injectedBackgroundColor
        }
        if message.isSentByCurrentUser {
            if message.type == .ephemeral {
                return colors.background8
            } else {
                return colors.chatBackgroundOutgoing
            }
        } else {
            return colors.chatBackgroundIncoming
        }
    }
}
