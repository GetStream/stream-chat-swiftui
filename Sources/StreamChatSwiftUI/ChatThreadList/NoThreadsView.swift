//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default SDK implementation for the view displayed when there are no threads available.
public struct NoThreadsView: View {
    @Injected(\.images) private var images

    public init() {}

    public var body: some View {
        NoContentView(
            image: images.noThreads,
            title: nil,
            description: L10n.Thread.NoContent.message,
            shouldRotateImage: false
        )
        .accessibilityIdentifier("NoThreadsView")
    }
}
