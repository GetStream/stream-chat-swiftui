//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A banner view that is displayed when there is an error loading the thread list.
public struct ChatThreadListErrorBannerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        ActionBannerView(
            text: L10n.Thread.Error.message,
            image: images.restart,
            action: action
        )
    }
}
