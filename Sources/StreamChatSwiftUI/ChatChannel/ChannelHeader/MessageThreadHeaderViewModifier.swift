//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View modifier for customizing the message thread header.
public protocol MessageThreadHeaderViewModifier: ViewModifier {}

/// The default message thread header.
public struct DefaultMessageThreadHeader: ToolbarContent {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text(L10n.Message.Actions.threadReply)
                    .font(fonts.bodyBold)
                Text(L10n.Message.Threads.subtitle)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
    }
}

/// The default message thread header modifier.
public struct DefaultMessageThreadHeaderModifier: MessageThreadHeaderViewModifier {

    public func body(content: Content) -> some View {
        content.toolbar {
            DefaultMessageThreadHeader()
        }
    }
}
