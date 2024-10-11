//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct ChatThreadListErrorBannerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    let action: () -> Void

    public var body: some View {
        ActionBannerView(
            text: L10n.Thread.Error.message,
            image: images.restart,
            action: action
        )
    }
}
