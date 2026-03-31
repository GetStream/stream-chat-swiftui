//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default SDK implementation for the view displayed when there are no channels available.
///
/// Different view can be injected in its place.
public struct EmptyChannelsView: View {
    @Injected(\.images) private var images

    public var body: some View {
        EmptyContentView(
            image: images.noContent,
            title: L10n.Channel.NoContent.title,
            description: L10n.Channel.NoContent.message,
            shouldRotateImage: true
        )
        .accessibilityIdentifier("EmptyChannelsView")
    }
}
