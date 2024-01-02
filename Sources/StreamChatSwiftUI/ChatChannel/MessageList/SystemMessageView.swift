//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View displaying system messages.
public struct SystemMessageView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        Text(message)
            .font(fonts.caption1)
            .bold()
            .foregroundColor(Color(colors.textLowEmphasis))
            .standardPadding()
            .accessibilityIdentifier("SystemMessageView")
    }
}
