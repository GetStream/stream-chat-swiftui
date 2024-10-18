//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default SDK implementation for the view displayed when there are no threads available.
public struct NoThreadsView: View {

    public init() {}

    public var body: some View {
        NoContentView(
            imageName: "text.bubble",
            title: nil,
            description: L10n.Thread.NoContent.message,
            shouldRotateImage: false
        )
        .accessibilityIdentifier("NoThreadsView")
    }
}
