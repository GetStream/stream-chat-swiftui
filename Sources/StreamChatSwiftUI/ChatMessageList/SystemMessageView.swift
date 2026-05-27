//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View displaying system messages.
public struct SystemMessageView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        Text(message)
            .font(fonts.footnote)
            .foregroundColor(Color(colors.chatTextSystem))
            .padding(.vertical, tokens.spacingXs)
            .padding(.horizontal, tokens.spacingSm)
            .accessibilityIdentifier("SystemMessageView")
            .background(Color(colors.backgroundCoreSurfaceSubtle))
            .cornerRadius(tokens.radiusXl)
            .overlay(
                RoundedRectangle(cornerRadius: tokens.radiusXl)
                    .stroke(Color(colors.borderCoreSubtle), lineWidth: 1)
            )
            .standardPadding()
            .frame(maxWidth: .infinity)
    }
}
