//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Image attachment preview for message references (photo attachments).
public struct ReferenceMessageImagePreviewView: View {
    @Injected(\.tokens) private var tokens

    let image: Image

    public init(image: Image) {
        self.image = image
    }

    public var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: tokens.radiusMd, style: .continuous))
    }
}
