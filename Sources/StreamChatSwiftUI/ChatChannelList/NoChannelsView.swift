//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default SDK implementation for the view displayed when there are no channels available.
///
/// Different view can be injected in its place.
public struct NoChannelsView: View {

    public var body: some View {
        NoContentView(
            imageName: "message",
            title: L10n.Channel.NoContent.title,
            description: L10n.Channel.NoContent.message,
            shouldRotateImage: true
        )
        .accessibilityIdentifier("NoChannelsView")
    }
}
